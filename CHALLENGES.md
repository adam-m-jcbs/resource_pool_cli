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

## How to develop productively in a field with a proliferation of tools, platforms, and users?

Challenge:

It is extremely difficult to develop productively in collaboration with teams of people deploying a dizzying array of tools/platforms/etc.  Yet collaboration is a non-negotiable when it comes to engineering nimbly, iteratively, and at scale in production.

Solution 1:

Centralize my code development in an open source GitHub repository that all collaborators have access to.  Even if they do not actively collaborate on the project, GitHub provides a rich set of tools for free that help to document and make legible the process of engineering a solution in code.

Solution 2:

It was a minor distraction during which I could've been developing, but I took the time to setup the AWS CLI.  Took a few minutes and is infinitely better than the console web interface.  Now I'm able to work much more efficiently, enabling more time for collaboration and the ability to get answers to collaborators fast.



## How to automate my infra's bootstrapping while respecting best practices

This is a pretty broad challenge, but here's a specific example:

I like to always update the systems at the base of my infrastructure (such as the OS), if for no other reason than to get security and bug fix patches in.  However, for many OS images in use, this can require a restart to fully take effect.  It's a difficult challenge to know when it's worth it to setup a more involved startup process with reboots integrated, or if it's sufficient to get the updates that are immediatley available without a reboot.  Or perhaps there is a way to completley obviate the need for reboot.  I know how to do this in some operating systems, but not all.  I could probably engineer a robust solution by building on top of an Arch linux image.

Some applications and the software they may leverage are poor at adapting to rapidly evolving environments, so there's also the risk that using the latest updates will break software being deployed.  If this is the case, I would want to evaluate the team's build process so that we can better isolate the software from envinornment dependencies that aren't mission-critical.  It is just too risky to not be running your software on a platform with the latest security and bug fixes applied.

Anyway, my current solution to the problem is to live with the updates I get immediately without reboot and to revisit this choice if I find my users or their software require updates to be fully applied.

Update: in engineering a solution to this and developing a more complete understanding of `user_data`, I believe careful use of it can pretty simply achieve the core of what I need here.



## Minor/Quality of Life/Best Practices/Security

- package resource_pool_cli as actual cli bin/script, instead of just a `.sh` in home.  Have setup.sh do this
- consolidate all user variables and files, get them more seamlessly (IAM user should be var, all files that are wget'd should be from nice, known, controlled source.  You probably don't want to be wget'ing raw files from GitHub ever, unless you simply must
- make sure sudo privileges allow exactly the commands applications developers should be using, no others
- implement auto-completion for the cli
- rename all "captain" reference to "jumphost"
- harden IAM config
- convert all python2 to python3
