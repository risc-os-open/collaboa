require 'html_pipeline'
require 'selma'

module WhiteListFormattedContentConcern
  extend ActiveSupport::Concern

  # Just a namespace for a modification of HTML Pipeline's defaults.
  #
  class CustomHtmlSanitizationOptions
    CONFIG = Selma::Sanitizer::Config.freeze_config({
      elements: [
        "a",
        "abbr",
        "b",
        "blockquote",
        "br",
        "caption",
        "cite",
        "code",
        "dd",
        "del",
        "dfn",
        "div",
        "dl",
        "dt",
        "em",
        "figcaption",
        "figure",
        "font",
        "h1",
        "h2",
        "h3",
        "h4",
        "h5",
        "h6",
        "hr",
        "i",
        "img",
        "ins",
        "kbd",
        "li",
        "ol",
        "p",
        "pre",
        "q",
        "s",
        "small",
        "span",
        "strike",
        "strong",
        "sub",
        "summary",
        "sup",
        "table",
        "tbody",
        "td",
        "tfoot",
        "th",
        "thead",
        "tr",
        "tt",
        "ul",
      ],
      attributes: {
        "a"          => ["href"],
        "blockquote" => ["cite"],
        "del"        => ["cite"],
        "div"        => ["itemscope", "itemtype"],
        "img"        => ["src", "longdesc", "loading", "alt"],
        "ins"        => ["cite"],
        "q"          => ["cite"],
        "source"     => ["srcset"],
        "span"       => ["class"],
        "table"      => ["class"],
        all: [
          "abbr",
          "accept-charset",
          "align",
          "alt",
          "aria-describedby",
          "aria-hidden",
          "aria-label",
          "aria-labelledby",
          "background-color",
          "border",
          "charset",
          "clear",
          "color",
          "cols",
          "colspan",
          "compact",
          "dir",
          "disabled",
          "enctype",
          "hspace",
          "id",
          "ismap",
          "itemprop",
          "label",
          "lang",
          "maxlength",
          "media",
          "method",
          "multiple",
          "name",
          "nowrap",
          "open",
          "readonly",
          "rel",
          "rev",
          "role",
          "rows",
          "rowspan",
          "rules",
          "scope",
          "selected",
          "shape",
          "size",
          "span",
          "start",
          "style",
          "summary",
          "tabindex",
          "title",
          "type",
          "usemap",
          "valign",
          "value",
          "width",
        ],
      },
      protocols: {
        "a"          => { "href" => Selma::Sanitizer::Config::VALID_PROTOCOLS }.freeze,
        "blockquote" => { "cite" => ["http", "https", :relative].freeze },
        "del"        => { "cite" => ["http", "https", :relative].freeze },
        "ins"        => { "cite" => ["http", "https", :relative].freeze },
        "q"          => { "cite" => ["http", "https", :relative].freeze },
        "img"        => {
          "src"      => ["http", "https", :relative].freeze,
          "longdesc" => ["http", "https", :relative].freeze,
        },
      },
    })
  end

  # https://github.com/gjtorikian/html-pipeline#textfilters
  #
  # Textile processing via RedCloth.
  #
  # Implemented as a TextFilter not a ConvertFilter because HTMLPipeline only
  # allows one convert filter to turn 'text into HTML', even though example
  # text filters *also* turn (at least part of) text into HTML. Auto-linking,
  # if used, must be done *after* RedCloth processing, else the URLs that are
  # part of valid RedCloth link syntax would get incorrectly auto-linked too.
  # We need a chain of filters; only the text filter system supports that.
  #
  class TextileTextFilter < HTMLPipeline::TextFilter
    def call(text, context: {}, result: {})
      return RedCloth.new(text).to_html()
    end
  end

  # https://github.com/gjtorikian/html-pipeline#textfilters
  #
  # Auto-links anything not already converted to a link through e.g. Textile
  # '"foo":link' markup or other means.
  #
  # See RedClothTextFilter for text filter rationale.
  #
  class AutoLinkTextFilter < HTMLPipeline::TextFilter
    include ActionView::Helpers::TextHelper

    def call(text, context: {}, result: {})

      # Sanitization is disabled as we use CustomHtmlSanitizationOptions for
      # that via the HTML pipeline; Auto Link's variant is very aggressive..
      #
      html = auto_link(text, sanitize: false) do | link_text |
        truncate(link_text, length: 55, omission: '&hellip;')
      end

      return html
    end
  end

  included do
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::TextHelper

    protected

      def xhtml_sanitize(content, textile: true, auto_link: true)
        if content.blank?
          ''
        else
          content.strip! if content.respond_to?(:strip!)

          text_filters  = []
          text_filters <<  TextileTextFilter.new if textile
          text_filters << AutoLinkTextFilter.new if auto_link

          pipeline = HTMLPipeline.new(
            text_filters:        text_filters,
            sanitization_config: CustomHtmlSanitizationOptions::CONFIG,
          )

          # Even if the output hasn't run through Textile, auto-link or any
          # other filters or converters, it's always run through the sanitiser
          # and is thus marked as HTML-safe for the view layer.
          #
          result = pipeline.call(content)
          (result[:output] || '').html_safe()
        end
      end

  end
end
