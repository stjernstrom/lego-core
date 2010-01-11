require File.join('spec', '/spec_helper')

describe 'Full stack request' do

  context 'with no routes specified' do
    before do
      class MyApp < Lego::Controller; end
      rack_env = {
      'PATH_INFO' => '/' ,
      'REQUEST_METHOD' => 'GET'
      }
      @result = MyApp.call(rack_env)
    end

    it 'should respond with a valid 404 response' do
      @result[0].should eql(404)
      @result[1].should eql({"Content-Type"=>"text/html"})
      @result[2].should eql('404 - Not found')
    end

    after do
      rm_const 'MyApp'
    end
  end

end
