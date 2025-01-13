# Copied out of source views in:
#
#   https://api.rubyonrails.org/v2.3.8/classes/ActionView/Helpers/JavaScriptHelper.html
#
# ...with very minor modernisation here and there.
#
module LegacyJavascriptHelper

  JS_ESCAPE_MAP = {
    '\\'   => '\\\\',
    '</'   => '<\/',
    "\r\n" => '\n',
    "\n"   => '\n',
    "\r"   => '\n',
    '"'    => '\\"',
    "'"    => "\\'"
  }

  # https://api.rubyonrails.org/v2.3.8/classes/ActionView/Helpers/JavaScriptHelper.html#M002232
  #
  def link_to_function(name, *args, &block)
    html_options = args.extract_options!.symbolize_keys

    function = block_given? ? update_page(&block) : args[0] || ''
    onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function}; return false;"
    href = html_options[:href] || '#'

    tag.a(name, **html_options.merge(href: href, onclick: onclick))
  end

  # https://api.rubyonrails.org/v2.3.8/classes/ActionView/Helpers/JavaScriptHelper.html#M002236
  #
  def options_for_javascript(options)
    if options.empty?
      '{}'
    else
      "{#{options.keys.map { |k| "#{k}:#{options[k]}" }.sort.join(', ')}}"
    end
  end

end
