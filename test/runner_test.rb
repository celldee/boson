require File.dirname(__FILE__) + '/test_helper'

class MyRunner < Boson::Runner
  desc "This is a small"
  def small(*args)
    p args
  end

  option :spicy, type: :boolean, desc: 'hot'
  desc "This is a medium"
  def medium(arg=nil, opts={})
    p [arg, opts]
  end

  def quiet
  end

  def boom
    nil.boom
  end

  def broken
    raise ArgumentError
  end

  private
  def no_run
  end
end

describe "Runner" do
  before_all { $0 = 'my_command'; reset }

  def my_command(cmd='')
    capture_stdout do
      MyRunner.start cmd.split(/\s+/)
    end
  end

  it "prints sorted commands by default" do
    my_command.should == <<-STR
Usage: my_command COMMAND [ARGS]

Available commands:
  boom
  broken
  medium  This is a medium
  quiet
  small   This is a small
STR
  end

  describe "for -h COMMAND" do
    it "prints help for descriptionless command" do
      my_command('-h quiet').should == <<-STR
Usage: my_command quiet

Description:
  TODO
STR
    end

    it "prints help for optionless command" do
      my_command('-h small').should == <<-STR
Usage: my_command small [*args]

Description:
  This is a small
STR
    end

    it "prints help for command with options" do
      my_command('-h medium').should == <<-STR
Usage: my_command medium [arg=nil]

Options:
  -s, --spicy  hot

Description:
  This is a medium
STR
    end

    it "prints error message for nonexistant command" do
      my_command('-h blarg').chomp.should ==
        'Could not find command "blarg"'
    end
  end

  it "handles command with default arguments correctly" do
    my_command('medium').chomp.should == '[nil, {}]'
  end

  it "calls command with options correctly" do
    my_command('medium 1 --spicy').chomp.should == '["1", {:spicy=>true}]'
  end

  it "calls optionless command correctly" do
    my_command('small 1 2').chomp.should == '["1", "2"]'
  end

  it "calls command with too many args" do
    MyRunner.expects(:abort).with <<-STR.chomp
'medium' was called incorrectly.
medium [arg=nil][--spicy]
STR
    my_command('medium 1 2 3')
  end

  it "prints error message for internal public method" do
    MyRunner.expects(:abort).with %[Could not find command "to_s"]
    my_command('to_s')
  end

  it "prints error message for nonexistant command" do
    MyRunner.expects(:abort).with %[Could not find command "blarg"]
    my_command('blarg')
  end

  it "allows no method error in command" do
    assert_error(NoMethodError) { my_command('boom') }
  end

  it "allows no method error in command" do
    assert_error(ArgumentError) { my_command('broken') }
  end

  it "prints error message for private method" do
    MyRunner.expects(:abort).with %[Could not find command "no_run"]
    my_command('no_run')
  end

  describe "$BOSONRC" do
    before { ENV.delete('BOSONRC') }

    it "is not loaded by default" do
      MyRunner.expects(:load).never
      my_command('quiet')
    end

    it "is loaded if set" do
      ENV['BOSONRC'] = 'whoop'
      File.expects(:exists?).returns(true)
      MyRunner.expects(:load).with('whoop')
      my_command('quiet')
    end

    after_all { ENV['BOSONRC'] = File.dirname(__FILE__) + '/.bosonrc' }
  end
end
