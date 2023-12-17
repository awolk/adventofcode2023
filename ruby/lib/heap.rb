Node = Struct.new(:item, :score)

class MinHeap
  def initialize(&blk)
    @scorer = blk || :itself.to_proc
    @heap = []
  end

  def add(item)
    node = Node.new(item, @scorer.call(item))
    index = @heap.length
    @heap << node
    while index > 0
      parent = index / 2
      if node.score < @heap[parent].score
        @heap[index], @heap[parent] = @heap[parent], @heap[index]
        index = parent
      else
        return
      end
    end
  end

  def pop
    return nil if @heap.empty?
    return @heap.pop.item if @heap.length == 1
    res = @heap[0]
    @heap[0] = @heap.pop

    index = 0
    while index < @heap.length
      child1_ind = index * 2 + 1
      break if child1_ind >= @heap.length
      child2_ind = index * 2 + 2

      smaller_child = if child2_ind == @heap.length
          child1_ind
        else
          [child1_ind, child2_ind].min_by {|i| @heap[i].score}
        end
      break if @heap[index].score < @heap[smaller_child].score

      @heap[smaller_child], @heap[index] = @heap[index], @heap[smaller_child]
      index = smaller_child
    end

    res.item
  end

  def empty?
    @heap.empty?
  end
end