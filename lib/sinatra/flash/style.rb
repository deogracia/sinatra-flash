module Sinatra
  module Flash

    # Handles the styling of flash in Sinatra views via the use of a helper method.
    module Style

      # This block provides the default styling for the styled_flash method.
      DEFAULT_BLOCK = ->(id,vals) do
        %Q!<div id='#{id}'>\n#{vals.collect{|message| "  <div class='flash #{message[0]}'>#{message[1]}</div>\n"}}</div>!
      end

      # A view helper for rendering flash messages to HTML with reasonable CSS structure. Handles 
      # multiple flash messages in one request.
      #
      # @overload styled_flash(key)
      #   @param [optional, String, Symbol] key Specifies which flash collection you want to display. 
      #     If you use this, the collection key will be appended to the top-level div id (e.g.,
      #     'flash_login' if you pass a key of  :login).
      #   Wraps them in a <div> tag with id #flash containing
      #   a <div> for each message with classes of .flash and the message type.  E.g.:
      #
      #   @example
      #     <div id='flash'>
      #       <div class='flash info'>Today is Tuesday, April 27th.</div>
      #       <div class='flash warning'>Missiles are headed to destroy the Earth!</div>
      #     </div>
      #
      #   It is your responsibility to style these classes the way you want in your stylesheets.
      #
      # @overload styled_flash(key, &block)
      #   @param [optional, String, Symbol] key Specifies which flash collection you want to display. 
      #     If you use this, the collection key will be appended to the top-level html structure's id (e.g.,
      #     'flash_login' if you pass a key of  :login).
      #   @yield [id,vals] block 
      #   @yieldparam [String] id The id to be used for the attribute id of the html output.
      #   @yieldparam [Hash] vals This param is for the values found in the flash hash by the key given.
      #
      #   @example Change the default style from a div to a list.
      #     my_styling = ->(id,vals){ %Q!<ul id='#{id}'>\n#{vals.collect{|message| "  <li class='flash #{message[0]}'>#{message[1]}</li>\n"}}</ul>! }
      #     styled_flash(:info, &my_styling)
      # @return [String] Styled HTML if the flash contains messages, or an empty string if it's empty.
      def styled_flash(key=:flash, &block)
        if key.respond_to? :call
          block = key
          key = :flash
        end
        return "" if flash(key).empty?
        id = (key == :flash ? "flash" : "flash_#{key}")
        block = DEFAULT_BLOCK if block.nil?
        output = block.call(id,flash(key))
      end

    end
  end
end


