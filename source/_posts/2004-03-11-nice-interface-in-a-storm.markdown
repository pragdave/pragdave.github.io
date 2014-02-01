---
layout: post
title: "Nice Interface in a Storm"
date: 2004-03-11 19:00:00 -0600
comments: true
categories: []
---

My Powerbook’s hard drive came to a sticky end yesterday. Almost
literally. Starting in the morning, it seemed to “stick” every now and
then, and applications would hang until it came back. The sticking got
worse and worse until eventually everything just died.


Down to the Apple store, and Tony in the Genius Bar said “before we
wipe it, why not take an full disk copy to be on the safe side. It’ll
probably cool down enough overnight that you’ll be able to get to the
disk.” And he recommended <a
href="http://www.bombich.com/software/ccc.html">Carbon Copy
Clone</a> as a way of getting a hard drive copied onto and external
firewire drive.


And it all worked. I downloaded the software, booted up in the
morning, and copied 40Gb onto an external LaCie drive. My hard drive
resisted a few times, but judicious tapping of the case seemed to
bring it back to life. When it finished, I rebooted off the firewire
drive, and was able to create a book PDF to send to the printers
before the weekend.


Along the way, I came to admire the Carbon Copy Clone interface. It’s
trivial: it basically asks you where to copy from and to, and gives
you a “start” button. But what makes it great is the log window. You
see, underneath the covers, CCC simply uses BSD commands to do its
work (things like ditto and bless). And in the log window, it shows
you these commands as it executes them. First, that means that as the
backup is happening, you can track the progress. I had a couple of
terminal windows open to I could see directories being created in
response to the commands that CCC was issuing. That made it easy to
tell when the hard drive had stalled.


But it’s also a great interface because it taught me two or three new
commands: things I hadn’t tried before. After I’d got a new loaner
Powerbook powered up, I found myself using ditto a lot to install
particular applications and directory trees.


So, for me at least, CCC is a really good example of a mixed-mode
interface. It’s a GUI when I needed it (I have to admit to being
panicky when the drive failed, and the idea of pressing a single
“start” button to make an archive was appealling). At the same time,
it also encouraged me to understand what was_really_ happening under
the covers, knowledge I put to good use later in the day.


And now I’m thinking about the applications I write. Do I perhaps hide
too much of what’s going on from my users? If I made it more explicit,
would it help them become more proficient?


Anyway, kudos to Mike Bombich for Carbon Copy Clone. (And thanks to
Tony at the Willow Bend Apple Store for the loaner machine).

