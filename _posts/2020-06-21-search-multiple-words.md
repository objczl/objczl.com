---
layout: post
title: Search Multiple Words in Terminal
date: 2020-06-21
categories: [cli]
---

I write notes with [nvALT](https://brettterpstra.com/projects/nvalt/) and vim, I
always do search with terminal, but I had suffered that it’s hard to search
multiple words with `AND` condition in a file. It’s easy to search in IDE.

I want a simple way to search multiple words in terminal.

I have googled on GitHub and StackOverflow but didn’t find a nice solution for
the multiple word search. So I write a simple script to complete the work.

**1. Install `ripgrep` with [brew](https://brew.sh/)**

```bash
brew install ripgrep
```

> The [ripgrep](https://github.com/BurntSushi/ripgrep) is best at searching with
> fast speed and highlighted words, I write the script base on `ripgrep`.

**2. Download [`search.sh`](https://v.gd/oNQRTp)**

```bash
curl -O https://raw.githubusercontent.com/objczl/hacker-scripts/master/search.sh
chmod +x search.sh
```

**3. Usage**

```bash
search.sh hello world
```

