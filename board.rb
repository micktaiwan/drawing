require 'gnomecanvas2'
require 'circle'

# TODO: teams force indicator

class Viewer < Gtk::Window
  def initialize(board)
    super()
    set_title("Virus Wars")
    signal_connect("delete_event") { |i,a| board.destroy }
    set_default_size(600,600)
    add(board)
    show()
  end
end

class Board < Gtk::VBox

  attr_reader :virus, :level, :current_level
  #attr_accessor


  def initialize(is_admin)
    super()
    @circles        = []
    @box = Gtk::EventBox.new
    pack_start(@box)
    set_border_width(@pad = 0)
    set_size_request((@width = 48)+(@pad*2), (@height = 48)+(@pad*2))
    @canvas = Gnome::Canvas.new(true)
    @box.add(@canvas)
    @box.set_visible_window(@canvas)

    @box.signal_connect('size-allocate') { |w,e,*b|
      @width, @height = [e.width,e.height].collect{|i|i - (@pad*2)}
      @canvas.set_size(@width,@height)
      @canvas.set_scroll_region(0,0,@width,@height)
      @bg.destroy if @bg
      @bg = Gnome::CanvasRect.new(@canvas.root, {
        :x1 => 0,
        :y1 => 0,
        :x2 => @width,
        :y2 => @height,
        :fill_color_rgba => 0x444444FF})
      @bg.lower_to_bottom
      false
      }

    @box.signal_connect('button-press-event') do |owner, ev|
      @circles << Circle.new(@canvas, ev.x, ev.y)
      @mouse_down = true
      false
    end

    @box.signal_connect('motion_notify_event') do |item,  ev|
      @circles << Circle.new(@canvas, ev.x, ev.y) if @mouse_down
      false
    end

    @box.signal_connect('button-release-event') do |owner, ev|
      @mouse_down = nil
      false
    end

    signal_connect_after('show') {|w,e| start() }
    signal_connect_after('hide') {|w,e| stop() }

    show_all()
  end

  def iterate
    update_circles
    while (Gtk.events_pending?)
      Gtk.main_iteration
    end
  end

  def update_circles
    @circles.each { |c|
      c.update
      if c.state == :nothing
        @circles.delete(c)
        c.destroy
      end
      }
  end

  def start
  	@started = true
  end

  def stop
  	@started = false
  end

end

