class Circle

  attr_reader :state
  Limit = 20
  Inc   = 3

  def initialize(canvas, x, y)
    @state = :growing
    @canvas = canvas
    @size = 2.0
    @x, @y = x, y
    @ellipse = Gnome::CanvasEllipse.new(@canvas.root, {
      :fill_color_rgba => 0x000000FF})
    @time = Time.now
    update
  end

  def update
    time = Time.now-@time
    case @state
    when :nothing
      return
    when :stable
      @state = :disapearing #if Time.now-@start_time > 1
    when :growing
      if @size > Limit
        @start_time = Time.now
        @state = :stable
      end
      @size += Inc*time
      s = @size / 2
      @ellipse.x1 = @x-s
      @ellipse.y1 = @y-s
      @ellipse.x2 = @x+s
      @ellipse.y2 = @y+s
    when :disapearing
      @state = :nothing if @size < 0.5
      @size -= Inc*time
      s = @size / 2
      @ellipse.x1 = @x-s
      @ellipse.y1 = @y-s
      @ellipse.x2 = @x+s
      @ellipse.y2 = @y+s
    end
    @time = Time.now
  end

  def destroy
    @ellipse.destroy
  end

end

