require "rmmseg"
class MMSeg
  def self.split(text)
    algor = RMMSeg::Algorithm.new(text)
    words = []
    loop do
      tok = algor.next_token
      break if tok.nil?
      words << tok.text
    end
    words
  end
end