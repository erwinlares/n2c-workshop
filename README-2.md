# From the Notebook to the Cluster

Participant materials for a three-day workshop series on taking an R analysis
from a notebook on your laptop to a high-throughput computing (HTC) cluster.
Each day uses one package, and each day builds on the last.

| Day | Date | Topic | Package |
|-----|------|-------|---------|
| 1 | Wednesday, October 7, 2026 | Scaffolding a reproducible project | [toolero](https://github.com/erwinlares/toolero) |
| 2 | Wednesday, October 14, 2026 | Containerizing it | [containr](https://github.com/erwinlares/containr) |
| 3 | Thursday, October 22, 2026 | Submitting it to a cluster | [submitr](https://github.com/erwinlares/submitr) |

**When:** 2:00 to 4:00 pm on each day.
**Where:** Computer Science 3139.
**What to bring:** a laptop with the software below installed.

Day 1 is done, and thank you to everyone who came. Its lesson stays online at
<https://erwinlares.github.io/n2c-workshop/>, and the Day 2 lesson is there
now. Day 3 appears the week it is taught.

## Before Day 2

Day 2 builds a container image from the analysis and sends it to a registry,
so everyone needs three things in place before the session. A container build
cannot be improvised in the room, and the two problems most likely to derail
the session are an engine that is not actually running and a registry login
that has not happened yet. Please try both before Wednesday.

1. **A container engine: Docker and/or Podman.** You need one of them, and
   either works. Platform-specific steps are in "Installing a container
   engine" below, followed by a check that it works.
2. **A GitLab account for `git.doit.wisc.edu`**, the UW-Madison DoIT GitLab
   service. Setup instructions are in the
   [DoIT knowledge base article](https://kb.wisc.edu/shared-tools/page.php?id=121442).
   You sign in with your NetID and Duo, so please test the login before the
   session.
3. **A personal access token (PAT) for the container registry**, and a
   successful login with it from your container engine. The session pushes
   images to `registry.doit.wisc.edu`, and your normal password will not work
   there. I wrote a short guide that walks through creating the token and
   logging in: <https://git.doit.wisc.edu/ERWIN.LARES/container-registry>.
   Please follow it before Day 2, and treat the token like a password.

Windows users also need WSL2 (Windows Subsystem for Linux, version 2), which
both Docker Desktop and Podman use on Windows.

You also need about 5 GB of free disk space. The first build downloads a base
image and installs every package the analysis uses from scratch, which is why
it runs through the break.

You already installed `containr` before Day 1. If you are joining the series
on Day 2, start with "If you missed Day 1" below, then come back here.

### Before Day 3

Day 3 submits jobs to the Center for High Throughput Computing (CHTC), so you
need a **CHTC account**. If you have not requested one yet, please do it now,
with the [CHTC account request form](https://chtc.cs.wisc.edu/uw-research-computing/form).
CHTC's page says to expect a follow-up in 2 to 3 business days after you submit
the form, and new research groups are first scheduled for a short consultation,
so the week before October 22 is already late. (Without an account you can
still follow Day 3 in preview mode, but you will not see your own jobs run.)

## Getting the materials for Day 2

On Day 2 everyone starts from the same project, rather than from the one you
built on Day 1. It is the fuller analysis I showed at the end of the Day 1
session (the same figure, plus a summary, a model, saved outputs, and a record
of them), and it is waiting for you as a download:
[`minimal-project-day2.zip`](https://github.com/erwinlares/n2c-workshop/releases/download/day2-checkpoint/minimal-project-day2.zip).
You can download it ahead of time or in the room; the lesson walks through
unzipping and opening it. Your Day 1 project stays on your disk, and nothing
on Day 2 touches it.

During the session you also download one more data file,
[`palmer-morphometrics-2025.csv`](https://github.com/erwinlares/n2c-workshop/blob/main/data/palmer-morphometrics-2025.csv),
which the analysis has never seen. The lesson says when.

As on Day 1, read the lesson in your browser and work in a single RStudio (or
Positron) session next to it.

**Optional: pull the fallback image ahead of time.** If your build fails on the
day, or your registry login does, you can carry on with a pre-built image of
the same project. It is public, so pulling it needs no login. On a network you
trust, run one of these the day before:

```bash
podman pull registry.doit.wisc.edu/erwin.lares/palmer-morphometrics-fallback:1.0.0
docker pull registry.doit.wisc.edu/erwin.lares/palmer-morphometrics-fallback:1.0.0
```

It is a large download, so this is entirely optional. If you skip it, you can
still pull it in the room if you need it.

## Installing a container engine

Pick the section for your operating system. These instructions come from the
official documentation of each project, which is the best place to look if
something changes after this was written.

### Windows

1. **Install WSL2.** Open PowerShell as an administrator (right-click, then
   "Run as administrator") and run:

   ```powershell
   wsl --install
   ```

   Restart your computer when it asks, then finish the Ubuntu setup (it asks
   you to choose a Linux username and password). To confirm you are on
   version 2, run `wsl.exe --list --verbose` and check that the VERSION column
   says 2. Microsoft's guide is
   [Install WSL](https://learn.microsoft.com/en-us/windows/wsl/install).

2. **Install a container engine.** Choose one:

   - **Docker Desktop:** follow
     [Install Docker Desktop on Windows](https://docs.docker.com/desktop/setup/install/windows-install/).
     When the installer asks, choose "Use WSL 2 instead of Hyper-V," then start
     Docker Desktop from the Start menu and accept the license terms.
   - **Podman:** follow the
     [Podman installation page](https://podman.io/docs/installation) and the
     [Podman for Windows guide](https://github.com/containers/podman/blob/main/docs/tutorials/podman-for-windows.md).
     Podman runs inside a WSL2 virtual machine, and you can use it from
     PowerShell.

### macOS

Choose one:

- **Docker Desktop:** follow
  [Install Docker Desktop on Mac](https://docs.docker.com/desktop/setup/install/mac-install/).
  Download the installer for your chip (Apple silicon or Intel), open
  `Docker.dmg`, drag Docker to the Applications folder, launch it, and accept
  the license terms. On Apple silicon, Docker also recommends installing
  Rosetta with `softwareupdate --install-rosetta`.
- **Podman:** download the installer from the
  [Podman installation page](https://podman.io/docs/installation), then
  create and start the virtual machine Podman uses on macOS:

  ```bash
  podman machine init
  podman machine start
  podman info
  ```

### Linux

Choose one:

- **Docker Engine:** follow the page for your distribution under
  [Install Docker Engine](https://docs.docker.com/engine/install/) (for
  example, [Ubuntu](https://docs.docker.com/engine/install/ubuntu/)), and then
  the [post-installation steps](https://docs.docker.com/engine/install/linux-postinstall/)
  so you can run `docker` without `sudo`.
- **Podman:** it is in most distributions' package repositories. On Debian or
  Ubuntu, run `sudo apt-get update && sudo apt-get -y install podman`. On
  Fedora, run `sudo dnf -y install podman`. Other distributions are listed on
  the [Podman installation page](https://podman.io/docs/installation).

### Check that it works

Whichever engine you chose, confirm it responds before the session. For
Docker, run:

```bash
docker run hello-world
```

For Podman, run `podman info`. If either command fails, write to me (see
"Getting help" below) with the exact error message.

Docker Desktop's license terms depend on how it is used. Docker explains them
on the installation pages linked above, and Podman is a free alternative if you
would rather not think about it.

## If you missed Day 1

Each day stands on its own, so you can join on Day 2. Please do the Day 1 setup
first, since Day 2 assumes it. Steps 1 to 4 take about 15 minutes if nothing
goes wrong.

1. Install R, version 4.4.0 or later, and [RStudio](https://posit.co/download/rstudio-desktop/).
   I built the lessons in RStudio, so the screens and menu names match it.
   [Positron](https://positron.posit.co/) should work with little or no
   change, and the lessons point out the few places where it differs.
2. Install [Quarto](https://quarto.org/docs/get-started/) and
   [Git](https://git-scm.com/downloads).
3. Start a fresh R session (not inside a project, and with none of these
   packages loaded) and install the three workshop packages from GitHub. We
   use the development versions of all three:

   ```r
   install.packages(c("pak", "readr", "ggplot2"))
   pak::pak("erwinlares/toolero")
   pak::pak("erwinlares/containr")
   pak::pak("erwinlares/submitr")
   ```

   If R reports that a "lazy-load database" is corrupt, a package was loaded
   while you were reinstalling it. Restart R and run the install again.

4. Run the setup check. It reports what is missing and does not change
   anything on your machine:

   ```r
   source("https://raw.githubusercontent.com/erwinlares/n2c-workshop/main/setup/check-setup.R")
   ```

   (If you would rather read the script before running it, it lives in
   [`setup/check-setup.R`](setup/check-setup.R).)

The Day 1 lesson is online with the others if you want to see where the
project came from. You do not need to work through it before Day 2.

## If you fall behind

On Day 2 everyone starts from the same checkpoint, so nobody arrives behind.
If something goes wrong during the session itself:

- **Your build fails or will not finish.** Pull the public fallback image
  (see "Getting the materials for Day 2") and use its name in place of your
  own in every command after that. You will rejoin at full speed.
- **Your registry login fails.** Watch a neighbor's push, and use the
  fallback image's address on Day 3. Write to me afterward and we will sort
  out the login before October 22.

Day 3 starts from its own checkpoint, so if Day 2 goes badly, you still
arrive at Day 3 on the same footing as everyone else.

| Starting point for | Download this checkpoint |
|--------------------|--------------------------|
| Day 2 (containr) | [`minimal-project-day2.zip`](https://github.com/erwinlares/n2c-workshop/releases/download/day2-checkpoint/minimal-project-day2.zip) |
| Day 3 (submitr) | [`minimal-project-day3.zip`](https://github.com/erwinlares/n2c-workshop/releases/download/day3-checkpoint/minimal-project-day3.zip) |

The Day 3 checkpoint is posted the week of Day 3, so its link will not work
before then.

## What is inside the repository

- `data/` holds the two CSV files: the 2024 measurements we used on Day 1,
  and the 2025 measurements for Day 2.
- `setup/` holds the setup check and the troubleshooting guide.
- `docs/` holds the rendered lessons, which are the pages you read online at
  <https://erwinlares.github.io/n2c-workshop/>.

## A note on the data

The two CSV files use the column names from the palmerpenguins package, with
units in the names (`bill_length_mm`, `bill_depth_mm`, `flipper_length_mm`,
`body_mass_g`). Day 1 used only the 2024 file. On Day 2 the 2025 file plays
the part of next season's measurements: data the containerized analysis has
never seen, handed to an image that was built without it.

R 4.5 and later also ship a `penguins` dataset in base R's `datasets`
package, but it names these columns differently (`bill_len`, `bill_dep`,
`flipper_len`, `body_mass`). If you load that version instead of the CSVs,
the lesson code will not find the columns it expects. The workshop always
reads the CSV file, so you do not need to load either package's data.

The split into "2024" and "2025" files is a teaching device. The original
measurements were collected between 2007 and 2009 (Gorman et al. 2014; see
`CITATION.cff`).

## Getting help

During the sessions, ask in the room. Between sessions, write to me directly
at <erwin.lares@wisc.edu>. If something fails, please include the exact error
message and the output of `sessionInfo()`. I would much rather hear about a
problem before the session than during it.

## How to cite

If you use these materials, GitHub's **Cite this repository** button (right
sidebar) gives you ready-made citations from `CITATION.cff`.

## License

The lesson text, figures, and documentation in this repository are licensed
under the [Creative Commons Attribution 4.0 International
License](LICENSE) (CC BY 4.0).

Code is licensed separately under the [MIT License](LICENSE-CODE). This covers
code snippets and code chunks shown in the lessons (R, shell, YAML, Dockerfile,
and HTCondor submit files), as well as scripts such as `setup/check-setup.R`.
You may reuse that code under MIT terms without attribution beyond keeping the
copyright notice.

The penguin data originate from the palmerpenguins package and the study cited
in the data note, and are released under CC0. The toolero, containr, and
submitr packages are separate projects with their own licenses.