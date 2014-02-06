# Colorizes text with ASCII colors.
# == Usage:
#   include ColorizedText
#
#   puts green "OK"          # => green output
#   puts bold "Running...    # => bold output
#   puts bold green "OK!!!"  # => bold green output
module ColorizedText
  # Colorize text using ASCII color code
  def colorize(text, code)
    "\033[#{code}m#{text}\033[0m"
  end

  # :nodoc:
  def yellow(text)
    colorize(text, 33)
  end

  # :nodoc:
  def green(text)
    colorize(text, 32)
  end

  # :nodoc:
  def red(text)
    colorize(text, 31)
  end

  # :nodoc:
  def bold(text)
    colorize(text, 1)
  end
end
