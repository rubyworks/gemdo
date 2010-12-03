<!--
h2. A Note or Two on Version Numbers

Though the taguri standard suggests using a dating scheme to
differentiate library versions in the directory hierarchy, Roll
fully supports both date and dot-series versioning. How to utilize either
of these is a matter to be decided by the project's maintainer.
But we'll touch on them briefly to help understand the two useful methods.

Series-versioning is the most common form versioning in use today. If you take
a close look at the versions put out by a plethora of projects you will also
notice that it is more akin to an art-form than a science[<a href="#foot1">1</a>].
Nonetheless, if you follow a strict Rational Versioning Policy
of "major.minor.tiny" with regards to project changes, it can be helpful
in conveying <i>compatibility</i>, which can in turn provide the end-user
some means of insurance that their programs will remain functional even
after updates.

Date-versioning, OTOH, is not as common mainly because it is not
typically thought to have any semantic value beyond a release timestamp.
But by creatively utilizing the taguri standard, date-versioning can in
fact lend itself to greater version consistency with regard to release
<i>stability</i>. Just follow these four simple rules:
<pre>
  1) Unstable/development releases provide the day (YYYY-MM-DD)
  2) Official/stable releases remove the day (YYYY-MM)
  3) Ultrastable releases provide only the year (YYYY)
  4) For daily builds add a "build moment" by adding the time.
</pre>
With this Rational Versioning Policy, the intent is clear and meaningful and
has a natural way of forcing one to comply to the meaning, which is nice.


<!--
To support versioning and to encourage clean divisions between projects,
Roll has taken a <i>inspiration</i> from the <b>taguri</b>
standard as a basis for library file and directory names.
You can learn more about taguri <a href="http://taguri.org">here</a>.
The taguri standard is not suitable in itself to designate file and
directory names, but with some basic transformations and additions it is
admirably useful. Here is an example of what a projects taguri would be and
how that translates into a directory structure and a tar package file name.

<pre>
  (1) tag:fruitbasket.rubyforge.org,2005-10-31:tryme.rb
  (2) fruitbasket.rubyforge.org/2005-10-31/tryme.rb
  (3) fruitbasket.rubyforge.org-2005.10.31.tgz (contains tryme.rb)
</pre>

The first is the standard taguri. The second is how it is
represented in file system. And the third is, of course,
the directory packed in a tar file. While we would have liked the
packaged file name to more closely resemble the original taguri,
many source host services do not allow file names to have commas.
But also notice how the the date becomes a sub-directory of the uri.
This represents the version, and as such it need not be a date
--it could just as well be a series like '1.0.0'.

For clarity here's the above as it translates into a project's directory
layout.
-->

<!--
<div id="footnotes">
Footnotes:<br/>
[1] <a href="http://www.newsforge.com/article.pl?sid=05/06/08/136214&from=rss">Decline and fall of the version number</a>
</div>
-->

