:author: `Eric Moyer`_
:copyright: Copyright © 2013 Eric Moyer <eric@lemoncrab.com>
:license: Modified BSD 

#####
Spiro
#####


Overview
========

Spiro is an kinetic spirographical curve demo written in Dart.

Source code: https://github.com/epmoyer/spiro

Web demo:    http://www.lemoncrab.com/spiro/spiro.html

Operation
=========

Spiro renders a virtual spirographical curve by implementing multiple wheels rotating at different speeds (a wheel on a wheel on a wheel...).
The center of each successive wheel rides around the circumfrence of the last, and the "pen" rides around the final wheel.
Becasuse the relative speeds are integer multiples of each other, the curve is guaranteed to close (though not guaranteed
to be non-overlapping).  Because the relative speeds can be both positive and negative, the curves can exhibit extremely interesting
behaviors.

Two different sets of spirograph coefficients (wheel radii and speeds) are randomly chosen and the program
smoothly slews between the two curves using a slew rate that is cosine mapped (so that the slew is slow near convergence
and fastest when midway between the two curves).  Once a curve converges, the oposite curve is randomized and the
process repeats.

The overall curve is also slowly rotated so that the start point doesn't boringly sit in the same place.


.. _`Eric Moyer`: mailto:eric@lemoncrab.com 