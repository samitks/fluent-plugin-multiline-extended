require 'fluent/plugin/in_tail'

module Fluent
  class NewNewTailInput < NewTailInput

    Plugin.register_input('tail_multiline_extended', self)

    def parse_multilines(lines, tail_watcher)
      if @parser.has_splitter?
        es = MultiEventStream.new
        tail_watcher.line_buffer_timer_flusher.reset_timer if tail_watcher.line_buffer_timer_flusher
        tail_watcher.line_buffer = tail_watcher.line_buffer.to_s + (lines.is_a?(Array) ? lines.join('') : '')
        tail_watcher.line_buffer = nil if tail_watcher.line_buffer =~ /^\s*$/
        if tail_watcher.line_buffer
          @parser.splitter(tail_watcher.line_buffer).each do |event|
            tail_watcher.line_buffer.partition(event)[2]
            @parser.parse(event) do |time, record|
              convert_line_to_event(event, es, tail_watcher)
            end
          end
        end
        tail_watcher.line_buffer = nil if tail_watcher.line_buffer =~ /^\s*$/
        es
      else
        super(lines, tail_watcher)
      end
    end

  end
end
