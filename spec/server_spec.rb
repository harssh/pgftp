# coding: utf-8

require 'spec_helper'

describe EM::FTPD::Server, "initialisation" do

  before(:each) do
    @c = EM::FTPD::Server.new(nil, PgFTPDriver.new)
  end

  it "should default to a root name_prefix" do
    @c.name_prefix.should eql("/")
  end

  it "should respond with 220 when connection is opened" do
    @c.sent_data.should match(/^220/)
  end
end



describe EM::FTPD::Server, "PASS" do
  before(:each) do
    @c = EM::FTPD::Server.new(nil, PgFTPDriver.new)
  end

  it "should respond with 202 when called by logged in user" do
    @c.receive_line("USER t")
    @c.receive_line("PASS 1")
    @c.reset_sent!
    @c.receive_line("PASS 1")
    @c.sent_data.should match(/202.+/)
  end
  
  
   it "should respond with 553 when called with no param" do
    @c.receive_line("USER test")
    @c.reset_sent!
    @c.receive_line("PASS")
    @c.sent_data.should match(/553.+/)
  end
  
  
end
