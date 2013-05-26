:author: `Eric Moyer`_
:copyright: Copyright © 2013 Eric Moyer <eric@lemoncrab.com>
:license: Modified BSD 

#####
Spiro
#####


Overview
========

Spiro is an animated spirograph demo written in Dart.  It is my first Dart project and my first client side web app.

Source code: https://github.com/epmoyer/spiro
Web demo:    http://www.lemoncrab.com/spiro

Operation
=========

Spiro renders a virtual spirograph by implementing three wheels rotating at different speeds (a wheel on a wheel on a wheel).
Becasuse the speeds are integer multiples of each other, the curve is guaranteed to close (though not guaranteed
to be non-overlapping).

Two different sets of spirograph coefficients (wheel radii and speeds) are randomly chosen and the program
smoothly slews between the two curves using a slew rate that is cosine mapped (so that the slew is slow near convergence
and fastest when midway between the two curves).  Once a curve converges, the oposite curve is randomized and the
process repeats.

The overall curve is slowly rotated so that the end point doesn't always sit in the same place boringly.


.. _`Eric Moyer`: mailto:eric@lemoncrab.com 