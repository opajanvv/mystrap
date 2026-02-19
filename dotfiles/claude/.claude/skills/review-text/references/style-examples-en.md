# Jan's English writing samples

These are examples of Jan's English writing style. Use them to understand tone, sentence structure, humor, and voice when reviewing English text.

---

## About page

Hi, I'm Jan van Veldhuizen.

From punch cards to AI: that's my career in one line. I studied mathematics in Leiden in the 1970s and fell in love with computers. I never finished the degree, but the computers never left. I found a job as a programmer and my hobby became my day job. Over the last thirty-odd years, I worked as a developer and software architect at Onguard. Since April 2025, I've been happily retired, back from career to hobby.

Online, I was known as "PapaSmurf", my nickname at work. But since my retirement I'm just Jan, "Opa Jan" to my grandkids.

At home, I've automated a lot, from lights to blinds. I have a powerful computer running pretty much everything, a "homelab", as they call it in the nerdy world. I experiment a lot and keep learning new programming languages. I also follow AI closely and occasionally give talks about it.

Away from tech, I play the organ in church services and enjoy foreign languages. You can find me browsing through dictionaries and grammar books for hours. My interest in languages is somewhat mathematical: I enjoy grammar more than literature or culture. My wife and I love long-distance walks and rides. In 2022 we cycled from home to Santiago de Compostela.

About this website: this is a hobby project too, and it obviously runs on my homelab. I'm planning to write three kinds of blog posts:

- All kinds of tech stuff (in English)
- Fun/interesting finds about language (often in Dutch)
- The occasional musing

So the site will have a mix of English and Dutch, and sometimes even Esperanto.

Thanks for visiting, and feel free to say hello.

---

## Blog: How my own blog helped me out

Last week someone played flashlight hide-and-seek in my car and left with my laptop. Yes, I know: leaving it there was dumb. But stupidity doesn't grant anyone permission to smash a window and go shopping. Anyway, the machine was gone.

I bought a new laptop, and you know what shows up when you unpack it and power it on: Windows! Aargh! So the very first action was to grab the Omarchy USB stick and install Linux.

The fresh Omarchy setup needed to be customized to what I was used to. And that's where my blog comes in. I could simply go through my own posts and copy-paste all the instructions. Present me is very grateful to past me for all this documentation.

Besides that, before installing Omarchy a few weeks ago, I made a complete backup of my system. So most data and files are still available. There's hardly anything lost.

Also, because Omarchy does full-disk encryption by default, they can't read anything on the stolen disk. They have a disk that they can wipe, that's it.

So, apart from the frustration and anger, I was happy with my own blog. I never expected to be my own customer.

---

## Blog: JanStrap: My Homelab Bootstrap System

I just realized that most of my Omarchy posts are basically pointless. Why? Because I stumbled on a solution so simple that it makes all my previous manual tweaking look unnecessarily complicated.

### The "Aha!" Moment

While browsing YouTube, I found typecraft's video about setting up Omarchy. He showed a straightforward approach: a Git repository with your packages, dotfiles, and a shell script that installs everything.

Run the script once, and your machine is configured exactly how you want it. Re-run it after updates, and everything stays in sync. Idempotent and zero manual tweaking.

I sat there thinking: "Why have I been writing blog posts about manually installing packages and editing configs when I could just... script it all?"

### The Homelab Problem

Here's my situation: I run multiple Omarchy workstations in my homelab. Each machine needs mostly the same setup, but with some host-specific differences:
- Laptop1 needs battery indicators and power management
- Desktop needs different monitor configurations
- All machines should share the same shell aliases, nvim config, and common packages

Previously, I'd install Omarchy, manually install packages, copy dotfiles around, SSH into each machine to make changes... You know, the tedious way.

### Enter JanStrap

I took typecraft's approach and pushed it to the next level. I built JanStrap: a complete bootstrap and configuration management system for my homelab.

What makes it special?

One repository, all machines. Common packages and dotfiles shared across all workstations, with easy host-specific overrides.

True idempotency. Run it once to bootstrap a fresh install. Run it again to apply updates. Run it a hundred times. It's always safe, never breaks anything.

Automatic propagation. Change your wallpaper config on laptop1, commit and push. Every other machine in your homelab can automatically pull and apply it. No SSH, no manual updates.

Smart dotfile overrides. Need a different waybar config on your laptop? Just override that one file. The rest stays shared. No duplication, no mess.

### How It Changes Everything

Remember my posts about installing essential packages? Adding Firefox configurations? Setting up workspaces? All of that is now:

```bash
./install_all.sh
```

Done. Everything installed, configured, and ready to go.

Update my shell aliases? Commit, push, and within an hour (or whatever schedule you choose), all machines have the new aliases. No intervention needed.

Fresh Omarchy install? Clone the repo, run the script, grab coffee. When you're back, your machine is exactly how you like it.

### Why I'm Not Explaining Everything

I could write a detailed guide about how JanStrap works: the package management, the GNU Stow integration, the host-specific override system, the automatic updates via cron.

You know what? I've already done that. Just hop over to the README file. It's all there: setup instructions, examples, the whole architecture.

What I *will* say is this: if you're running multiple Omarchy machines (or any Arch-based setup), and you're tired of manually keeping them in sync, check it out.

### Full Circle

So yeah, most of my previous Omarchy posts? Consider them deprecated. Or rather, think of them as the "before" picture. JanStrap is the "after."

I still learned valuable things while writing those posts. But now, instead of documenting *how* to configure things manually, I just maintain a Git repository that does it all automatically.

Sometimes the best solution is the simple one you should have built from the start.

---

## LinkedIn post: Bitbash event (short/functional post)

Any of my former Onguard development colleagues heading to Bitbash in two weeks?

It would be great to catch up! Come join this nerdy oldtimer. I'll be there both days.

---

## LinkedIn comment: AI development approach

Exactly. Use AI as a critical team-mate instead of a magician spitting out lines of code.

The development process doesn't change: think, design, plan, start small, verify and test often. That cycle can be sped up dramatically with AI.
