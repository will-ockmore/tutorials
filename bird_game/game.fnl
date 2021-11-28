(local fennel (require "lib.fennel"))

(var initial-bird-y 200)
(var bird-y initial-bird-y)
(var bird-y-speed 0)
(var bird-x 62)
(var bird-width 30)
(var bird-height 25)

(var playing-area-width 300)
(var playing-area-height 388)

(var pipe-space-height 100)
(var pipe-space-y-min 54)
(var pipe-width 54)

(var pipe-1-x 100)
(var pipe-1-space-y 100)
(var pipe-2-x 200)
(var pipe-2-space-y 200)

(var score 0)
(var upcoming-pipe 1)

(fn new-pipe-space-y [] 
  ;; Randomise pipe space position
    (love.math.random 
      pipe-space-y-min 
      (- 
        playing-area-height 
        pipe-space-height
        pipe-space-y-min)))

(fn collision? [pipe-x pipe-space-y] 
  ;; Does the bird collide with the pipe
  (and 
    ;; Left edge of bird is to the left of the right edge of the pipe
    (< bird-x (+ pipe-x pipe-width))
    ;; Right edge of the bird is to the right of the left edge of the pipe
    (> (+ bird-x bird-width) pipe-x)
    (or
      ;; Top edge of the bird is above the bottom edge of the first pipe segment
      (< bird-y pipe-space-y)
      ;; Bottom edge of the bird is below the top edge of the second pipe segment
      (> (+ bird-y bird-height) (+ pipe-space-y pipe-space-height)))))

(fn reset [] 
  (set score 0)
  (set upcoming-pipe 1)
  (set pipe-1-x playing-area-width)
  (set pipe-1-space-y (new-pipe-space-y))
  (set pipe-2-x 
       (+ 
         playing-area-width 
         (/ (+ playing-area-width pipe-width) 2)))
  (set pipe-2-space-y (new-pipe-space-y))
  (set bird-y initial-bird-y)
  (set bird-y-speed 0))

(fn love.load [] (reset))

(fn move-pipe [dt pipe-x pipe-space-y]
  (let [new-pipe-x (- pipe-x (* 60 dt))]
    (if 
      (< (+ new-pipe-x pipe-width) 0) 
      [playing-area-width (new-pipe-space-y)] 
      [new-pipe-x pipe-space-y])))

(fn love.update [dt] 
  ;; Update bird speed and position
  (set bird-y-speed (+ bird-y-speed (* 516 dt)))
  (set bird-y (+ bird-y (* bird-y-speed dt)))
  ;; Update pipe positions
  (set [pipe-1-x pipe-1-space-y] (move-pipe dt pipe-1-x pipe-1-space-y))
  (set [pipe-2-x pipe-2-space-y] (move-pipe dt pipe-2-x pipe-2-space-y))
  ;; Handle collisions and viewport boundary
  (when 
    (or 
      (collision? pipe-1-x pipe-1-space-y) 
      (collision? pipe-2-x pipe-2-space-y)
      (> bird-y playing-area-height)) 
    (love.load))
  ;; Update score
  (fn update-score-and-closest-pipe [this-pipe pipe-x other-pipe]
    (if
     (and (= upcoming-pipe this-pipe) (> bird-x (+ pipe-x pipe-width)))
     (set [score upcoming-pipe] [(+ score 1) other-pipe])))
    (update-score-and-closest-pipe 1 pipe-1-x 2)
    (update-score-and-closest-pipe 2 pipe-2-x 1))

(fn draw-pipe [pipe-x pipe-space-y]
   (love.graphics.setColor .37 .82 .28)
   (love.graphics.rectangle "fill"  pipe-x 0 pipe-width pipe-space-y)
   (love.graphics.rectangle 
     "fill"  
     pipe-x 
     (+ pipe-space-y pipe-space-height) 
     pipe-width
     (- playing-area-height pipe-space-y pipe-space-height)))

(fn love.draw []
   ;; Draw background
   (love.graphics.setColor .14 .36 .46)
   (love.graphics.rectangle "fill" 0 0 playing-area-width playing-area-height)
   ;; Draw bird
   (love.graphics.setColor .87 .84 .27)
   (love.graphics.rectangle "fill"  bird-x bird-y bird-width bird-height)
   ;; Draw pipes
   (draw-pipe pipe-1-x pipe-1-space-y)
   (draw-pipe pipe-2-x pipe-2-space-y)
   ;; Draw score
   (love.graphics.setColor 1 1 1)
   (love.graphics.print score  15 15))

(fn love.keypressed [key]
  (when (> bird-y 0)
    (set bird-y-speed -165)))
