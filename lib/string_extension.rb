module StringExtension
  def to_colored(col)
    color = {
      :black        => "\e[30m",
      :bold_black   => "\e[1;30m",
      :red          => "\e[31m",
      :bold_red     => "\e[1;31m",
      :green        => "\e[32m",
      :bold_green   => "\e[1;32m",
      :yellow       => "\e[33m",
      :bold_yellow  => "\e[1;33m",
      :blue         => "\e[34m",
      :bold_blue    => "\e[1;34m",
      :magenta      => "\e[35m",
      :bold_magenta => "\e[1;35m",
      :cyan         => "\e[36m",
      :bold_cyan    => "\e[1;36m",
      :white        => "\e[37m",
      :bold_white   => "\e[1;37m",
      :bold         => "\e[1m",
      :inverted     => "\e[7m"
    }
    return "#{color[col]}#{self}#{reset_color}"
  end

  def reset_color
    return "\e[0m"
  end

end

class String
  include StringExtension
end

