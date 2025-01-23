module GitLabEventsHelper

  # Return a sort of "wrappable <pre>" block of text as a paragraph with individual
  # lines wrapped by <code>...</code>, and leading non-breaking spaces for any
  # indenting spaces at the start of lines (but not thereafter).
  #
  def gitlabeventshelp_wrappable_pre(text)
    html = '<p>'

    tag.p do
      text.each_line do | line |
        line = h(line)
        line.sub!(/^\s*/) do | match |
          '&nbsp;' * match.length
        end

        concat(tag.code(line.strip().html_safe()))
        concat(tag.br)
      end
    end
  end
end
