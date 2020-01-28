# Engineering Challenges

This is a document for keeping track of and documenting my engineering challenges along with my solutions.

## How to leverage the value offered by cloud-native technology with a cloud-ignorant application?

Challenge: the use-case calls for not just high-availability, but the
robustness of high-availability possible in the cloud.  A rich suite of
technologies exist to implement high-availability that your company would not
have to maintain.  Oh, and you can stop managing hardware or significantly
scale-back your use of on-premises resources.

Solution: 

Decision 1: Fork an MVP project of a fellow developer within the company that did
some initial pilot work on this.  This pilot project has been utilized by team
members and is known to work with some existing applications.  This means
developers have familiarity with it and can use it.  By building on top of
this, potential future onboarding (assuming this MVP is successful) is made
easier.

Decision 2: Focus on building and illustrating the core feature desired: high
availability.  When balancing backward-compatibility (keeping apps in
production) against building out modern cloud workflows that may require
application changes or developer onboarding, let this priority guide the
decision.

## Next Challenge 
