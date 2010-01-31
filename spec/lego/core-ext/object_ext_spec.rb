class Dummy
  def f
    :dummy_value
  end
end

describe "Instance exec" do
  
  let(:dummy) { Dummy.new }

  it "with arguments" do
    # Create a block that returns the value of an argument and a value
    # of a method call to +self+.  
    block = lambda { |a| [a, f] }

    [:arg_value, :dummy_value].should eql(dummy.instance_exec(:arg_value, &block))
  end

  it "with frozen obj" do
    block = lambda { |a| [a, f] }

    dummy.freeze
    [:arg_value, :dummy_value].should eql(dummy.instance_exec(:arg_value, &block))
  end

  it "with nested instance_execs" do
    i = 0
    block = lambda do |arg|
      [arg] + instance_exec(1){|a| [f, a] }
    end

    # the following assertion expanded by the xmp filter automagically from:
    # obj.instance_exec(:arg_value, &block) #=>
    [:arg_value, :dummy_value, 1].should eql(dummy.instance_exec(:arg_value, &block))
  end
end
