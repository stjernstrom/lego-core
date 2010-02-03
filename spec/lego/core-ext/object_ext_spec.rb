class Dummy
  def f
    :dummy_value
  end
end

describe Object do
  context ".instance_exec" do
    
    let(:dummy) { Dummy.new }

    context "with argumets" do

      it "should return the value of an argument and a method call to +self+" do
        block = lambda { |a| [a, f] }

        [:arg_value, :dummy_value].should eql(dummy.instance_exec(:arg_value, &block))
      end
    end

    context "with frozen object" do

      it "should return the value of an argument and a method call to +self+" do
        block = lambda { |a| [a, f] }

        dummy.freeze
        [:arg_value, :dummy_value].should eql(dummy.instance_exec(:arg_value, &block))
      end
    end

    context "with nested instance_execs" do
      it "should return the value of an argument and a method call to +self+" do
        i = 0
        block = lambda do |arg|
          [arg] + instance_exec(1){|a| [f, a] }
        end

        # the following assertion expanded by the xmp filter automagically from:
        # obj.instance_exec(:arg_value, &block) #=>
        [:arg_value, :dummy_value, 1].should eql(dummy.instance_exec(:arg_value, &block))
      end
    end
  end
end
