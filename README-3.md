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

Days 1 and 2 are done. Their lessons stay online at
<https://erwinlares.github.io/n2c-workshop/>, and the Day 3 lesson is there
now.

## Before Day 3

Day 3 sends the containerized analysis to the Center for High Throughput
Computing (CHTC), first as one job and then as one job per species. Two
things need to be in place before Thursday, and the second one takes five
minutes.

1. **A CHTC account**, with access to a submit node such as
   `ap2002.chtc.wisc.edu`. If you requested one with the
   [CHTC account request form](https://chtc.cs.wisc.edu/uw-research-computing/form)
   and have not heard back after three business days, write to CHTC at
   <chtc@cs.wisc.edu>. If you do not have an account by Thursday, come
   anyway: every step that talks to CHTC has a preview mode that prints the
   exact command it would have run, and the lesson says where to use it.

2. **SSH connection reuse.** Every `submitr` function that talks to CHTC opens
   an SSH connection, and every fresh SSH connection to CHTC asks for Duo.
   Without connection reuse, one round trip (upload, submit, a few status
   checks, download) means a handful of Duo prompts. Connection reuse opens one
   authenticated connection and lets every later call share it. `submitr` sets
   it up for you. From R, on your laptop:

   ```r
   submitr::htc_ssh_setup()
   ```

   That adds a short block to `~/.ssh/config` and creates the folder it
   refers to. If you already have a matching block, it leaves your file alone
   and says so; run it with `dry_run = TRUE` first if you would like to see
   what it would write. Then open the shared connection once from a terminal,
   and approve Duo when asked:

   ```bash
   ssh your.netid@ap2002.chtc.wisc.edu
   ```

   The test that it worked: open a second terminal and run the same `ssh`
   line. It should log you in without a Duo prompt. CHTC's own guide is at
   <https://chtc.cs.wisc.edu/uw-research-computing/configure-ssh>.

   Windows users need the OpenSSH client (on Windows 10 and 11 it is an
   optional feature: open Settings, search for "optional features", and add
   "OpenSSH Client"). `htc_ssh_setup()` warns on Windows that connection reuse
   relies on Unix sockets; it may still work on a current OpenSSH, and if it
   does not, the preview mode covers you. If you are off campus, connect to
   WiscVPN before you try.

The shared connection lasts two hours, so on the day, open it shortly before
2:00 rather than in the morning.

Day 3 does not need a container engine, Docker or Podman, on your laptop. The
image lives in the registry, and CHTC pulls it from there.

## Getting the materials for Day 3

As on Day 2, everyone starts from the same project:
[`minimal-project-day3.zip`](https://github.com/erwinlares/n2c-workshop/releases/download/day3-checkpoint/minimal-project-day3.zip).
It is the Day 2 project plus the `Dockerfile` we generated there. Download it
ahead of time or in the room; the lesson walks through unzipping and opening
it.

The other thing you need from Day 2 is the image address `push_image()`
returned, something like
`registry.doit.wisc.edu/your.netid/palmer-morphometrics:1.0.0`. If you kept
it, bring it. If you do not have one (you missed Day 2, or your build or push
did not finish), use the public image I built from the same project:

```text
registry.doit.wisc.edu/erwin.lares/palmer-morphometrics-fallback:1.0.0
```

As on the earlier days, read the lesson in your browser and work in a single
RStudio (or Positron) session next to it.

## If you missed an earlier day

Each day stands on its own, so you can join on Day 3. Please do the Day 1 setup
first, since Day 3 assumes it, and then the two steps under "Before Day 3".

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

You do not need to have built or pushed an image yourself: the public image
above stands in for it.

## If you fall behind

Day 3 has no next checkpoint to jump to, so it has two safety nets instead.
Anyone whose SSH connection will not cooperate in the first few minutes
switches to the preview mode for the rest of the session, and pairs with a
neighbor whose jobs are running. Anyone whose job does not come back in time
can follow the rest of the lesson with mine, on screen.

Both checkpoints stay up after the series, for anyone who wants to go back over
a day:

| Starting point for | Download this checkpoint |
|--------------------|--------------------------|
| Day 2 (containr) | [`minimal-project-day2.zip`](https://github.com/erwinlares/n2c-workshop/releases/download/day2-checkpoint/minimal-project-day2.zip) |
| Day 3 (submitr) | [`minimal-project-day3.zip`](https://github.com/erwinlares/n2c-workshop/releases/download/day3-checkpoint/minimal-project-day3.zip) |

## What is inside the repository

- `data/` holds the two CSV files: the 2024 measurements, used on all three
  days, and the 2025 measurements, used on Day 2.
- `setup/` holds the setup check and the troubleshooting guide.
- `docs/` holds the rendered lessons, which are the pages you read online at
  <https://erwinlares.github.io/n2c-workshop/>.

## A note on the data

The two CSV files use the column names from the palmerpenguins package, with
units in the names (`bill_length_mm`, `bill_depth_mm`, `flipper_length_mm`,
`body_mass_g`). Day 3 splits the 2024 file by species and runs one job per
species; the 2025 file was the Day 2 stand-in for next season's measurements.

R 4.5 and later also ship a `penguins` dataset in base R's `datasets`
package, but it names these columns differently (`bill_len`, `bill_dep`,
`flipper_len`, `body_mass`). If you load that version instead of the CSVs,
the lesson code will not find the columns it expects. The workshop always
reads the CSV file, so you do not need to load either package's data.

The split into "2024" and "2025" files is a teaching device. The original
measurements were collected between 2007 and 2009 (Gorman et al. 2014; see
`CITATION.cff`).

## Installing a container engine (for Day 2)

Day 3 does not need a container engine. This section is here for anyone
revisiting Day 2. Pick the section for your operating system. These instructions come from the
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