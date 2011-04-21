module ArrayExtensions
  # 随机从数组里取出N个元素
  def random_pick(number)  
    sort_by{ rand }.slice(0...number)  
  end  
end

Array.send :include,ArrayExtensions