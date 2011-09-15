require 'test_helper'

class AskCellTest < Cell::TestCase
  test "followers" do
    invoke :followers
    assert_select "p"
  end
  

end
