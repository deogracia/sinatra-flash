require 'spec_helper'
require 'sinatra/flash/style'

describe 'styled_flash method' do
  include Sinatra::Sessionography  # for the 'session' method
  include Sinatra::Flash::Storage
  include Sinatra::Flash::Style

  before(:each) do
    Sinatra::Sessionography.session = {
      :flash => {:foo=>:bar, :too=>'tar'},
      :smash => {:yoo=>:yar, :zoo=>'zar'}
    }
  end

  it "returns an empty string if the flash is empty" do
    Sinatra::Sessionography.session = {}
    styled_flash.should == ""
  end

  it "returns a div of #flash if the structure is the default" do
    styled_flash.should =~ /<div id='flash'>/
  end

  it "contains each key as a class" do
    styled_flash.should =~ /<div class='flash foo'>bar<\/div>/
    styled_flash.should =~ /<div class='flash too'>tar<\/div>/
  end

  context "Given a key" do
    context "When that structure is empty" do
      it "returns an empty string" do
        styled_flash(:trash).should == ""
      end
    end

    context "When the structure is not empty" do
      it "returns a div containing the key name" do
        styled_flash(:smash).should =~ /<div id='flash_smash'>/
      end

      it "returns each of the keys within that key as a class" do
        styled_flash(:smash).should =~ /<div class='flash yoo'>yar<\/div>/
        styled_flash(:smash).should =~ /<div class='flash zoo'>zar<\/div>/
      end
    end
  end

  describe "Block style styling" do
    context "Given a block" do
      context " that is the same as the default" do
        let(:my_block) {
          ->(id,vals) do
            %Q!<div id='#{id}'>\n#{vals.collect{|message| "  <div class='flash #{message[0]}'>#{message[1]}</div>\n"}}</div>!
          end
        }

        context "When that structure is empty" do
          it "returns an empty string" do
            styled_flash(:trash, &my_block).should == ""
          end
        end

        context "When the structure is not empty" do
          it "returns a div containing the key name" do
            styled_flash(:smash, &my_block).should =~ /<div id='flash_smash'>/
          end

          it "returns each of the keys within that key as a class" do
            styled_flash(:smash, &my_block).should =~ /<div class='flash yoo'>yar<\/div>/
            styled_flash(:smash, &my_block).should =~ /<div class='flash zoo'>zar<\/div>/
          end
        end
      end

      context "That is different to the default" do
        let(:my_block) {
          ->(id,vals) do
            %Q!<ul id='#{id}'>\n#{vals.map{|message| "  <li class='flash #{message[0]}'>#{message[1]}</li>\n"}.join}</ul>!
          end
        }
        let(:smash){ "<ul id='flash_smash'>\n  <li class='flash yoo'>yar</li>\n  <li class='flash zoo'>zar</li>\n</ul>" }
        let(:just_flash) { "<ul id='flash'>\n  <li class='flash foo'>bar</li>\n  <li class='flash too'>tar</li>\n</ul>" }

        context "When that structure is empty" do
          subject { styled_flash(:trash, &my_block) }
          it { should == "" }
        end

        context "When the structure is not empty" do
          subject { styled_flash(:smash, &my_block) }
          it { should == smash }
        end

        context "Given a block in the standard style" do
          context "And a key" do
            subject {
              styled_flash :smash do |id,vals|
                %Q!<ul id='#{id}'>\n#{vals.map{|message| "  <li class='flash #{message[0]}'>#{message[1]}</li>\n"}.join}</ul>!
              end
            }
            it { should == smash }
          end
          context "And no key" do
            subject {
              styled_flash do |id,vals|
                %Q!<ul id='#{id}'>\n#{vals.map{|message| "  <li class='flash #{message[0]}'>#{message[1]}</li>\n"}.join}</ul>!
              end
            }
            it { should == just_flash }
          end
              
        end

      end
    end
  end

end