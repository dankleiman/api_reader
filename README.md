About API Reader
================

Using API Reader
----------------

First, enter a JSON object to search.

Then enter a search value.

You will get back a series the brackets (keys and indices) that you need to referrence the search value in your code.

If there is more than one occurrence of the value in the data structure (including key names), you will get a multiline return. Each line of the search results is a different reference path.

Possible Uses
-------------

You can use the results of the search to:

+ Directly reference a value inside of your code.
+ Simplify the nested structure of your data.
+ Guess and check - practice your JSON reading skills: figure out the path by hand first, then run this app to confirm.

Background
----------

As Junior Developers, we set out to learn about compound data structures.

Quickly, we encountered hashes and arrays, and hashes inside arrays...inside of hashes and arrays of hashes with more hashes and arrays inside of them.

When you want to identify a specific value inside of these compound structures, your head starts to spin as you keep track of all the nested keys and indices.

Bascially, we wanted to create an easier way to get the "path" of any value inside a compound data structure, so we could reference it in our code.

Problem Statement and Our Approach to Solving
---------------------------------------------

**Problem:** Given a value and a compound data structure, return the position in the strucure, formatted so you can referrence it in your code.

**Solution:** To find the value in the data structure you need to:

1. Traverse an array of hashes, potentially with nested arrays and/or hashes.
2. Test each element of the structure against the value you're searching for.
3. Keep track of the path through the structure.


We are in the process of refining the power of the search to work for all possible search values, including the keys of the nested hashes. Stay tuned!

[Here is the original repo on which this app is based.](https://github.com/dankleiman/path_finder)

