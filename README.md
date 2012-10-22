artisttree
==========

Given a wikipedia URL to a band or artist, retrieve all related acts and why they are related.

Example
==========
<pre>
% python artisttree.py 'http://en.wikipedia.org/wiki/Descendents'
Descendents ----
|- All (because of: Bill Stevenson, Stephen Egerton, Karl Alvarez)
| `- Dag Nasty (because of: Dave Smalley)
| `- Down By Law (because of: Dave Smalley)
|- Black Flag (because of: Bill Stevenson)
| `- Circle Jerks (because of: Keith Morris, Chuck Biscuits)
| `- Minutemen (because of: Greg Ginn, Raymond Pettibon, Chuck Dukowski, Henry Rollins, Kira Roessler)
| `- Dos (because of: Kira Roessler)
| `- Gone (because of: Greg Ginn, Henry Rollins)
| `- The Nig-Heist (because of: Greg Ginn, Dez Cadena, Chuck Biscuits, Bill Stevenson)
| `- October Faction (because of: Greg Ginn, Chuck Dukowski, Bill Stevenson)
| `- S.O.A. (because of: a Wikipedia author saying so)
| `- Rollins Band (because of: Henry Rollins)
| `- Chuck Dukowski Sextet (because of: Greg Ginn, Keith Morris, Raymond Pettibon, Spot, Chuck Dukowski, Robo, Ron Reyes, Dez Cadena, Henry Rollins, Chuck Biscuits, Bill Stevenson, Kira Roessler)
| `- SWA (because of: Greg Ginn, Chuck Dukowski)
| `- Misfits (because of: Robo, Dez Cadena)
| `- Redd Kross (because of: Ron Reyes, Dez Cadena)
| `- DC3 (because of: Dez Cadena, Kira Roessler)
 |- Only Crime (because of: Bill Stevenson)
| `- ALL (because of: Bill Stevenson)
| `- Bane (because of: Aaron Dalbec)
| `- Converge (because of: Aaron Dalbec)
| `- Good Riddance (because of: Russ Rankin)
| `- Hagfish (because of: Zach Blair, Doni Blair)
| `- State of Grace (because of: Russ Rankin)
----------------
</pre>