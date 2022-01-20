class Node
  attr_accessor :data, :left, :right

  include Comparable

  def initialize(data)
    @data = data
    @left = nil
    @right = nil
  end

  def <=>(other)
    data <=> other.data
  end

  def childrens
    [left, right]
  end

  def child_count
    childrens.compact.size
  end

  def successor
    left_successor || right_successor
  end

  # find biggest left descendant node
  def left_successor
    return unless left

    current = left
    value = current.data
    while current.right
      value = current.data if current.data > value
      current = current.right
    end
    current
  end

  # find smallest right descendant node
  def right_successor
    return unless right

    current = right
    value = current.data
    while current.left
      value = current.data if current.data < value
      current = current.left
    end
    current
  end
end

class Tree
  attr_reader :root

  def initialize(array)
    @root = build_tree(array)
  end

  def build_tree(array)
    return if array.empty?

    array = array.uniq.sort
    center = array.length / 2

    root = Node.new(array[center])
    root.left = build_tree(array[0...center])
    root.right = build_tree(array[center + 1..])
    root
  end

  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
  end

  def find(value, node = @root)
    return node if node.data == value

    left = node.left ? find(value, node.left) : nil
    right = node.right ? find(value, node.right) : nil
    left || right
  end

  def insert(value)
    return if find(value)

    insert_rec(value)
  end

  def insert_rec(value, node = @root)
    if value < node.data
      node.left ? insert_rec(value, node.left) : node.left = Node.new(value)
    else
      node.right ? insert_rec(value, node.right) : node.right = Node.new(value)
    end
  end

  def delete(value)
    return unless find(value)

    if @root.data == value
      new_node = @root.successor
      delete(new_node.data)
      new_node.right = @root.right
      new_node.left = @root.left
      @root = new_node
      return
    end

    delete_rec(value)
  end

  def delete_rec(value, node = @root)
    return unless node

    if node.left && node.left.data == value
      node.left = remove_node(node.left)
    elsif node.right && node.right.data == value
      node.right = remove_node(node.right)

    elsif node.left && value < node.data
      delete_rec(value, node.left)
    elsif node.right && value > node.data
      delete_rec(value, node.right)
    end
  end

  def remove_node(node)
    case node.child_count
    when 0
      nil
    when 1
      node.left || node.right
    when 2
      new_node = node.successor
      delete_rec(new_node.data, node)
      new_node.right = node.right
      new_node.left = node.left
      new_node
    end
  end

  def eval_nodes(nodes, &block)
    if block_given?
      nodes.map { |i| block.call(i) }
    else
      nodes.map { |i| i.data }
    end
  end

  def level_order(node = @root, &block)
    nodes = level_ord_rec(node)
    eval_nodes(nodes, &block)
  end

  def level_ord_rec(node)
    return [] unless node
    nodes = []
    nodes << node if node == @root
    nodes += node.childrens.compact
    nodes += level_ord_rec(node.left) if node.left
    nodes += level_ord_rec(node.right) if node.right
    nodes
  end
end

tree = Tree.new((0..5).to_a)
tree.pretty_print
