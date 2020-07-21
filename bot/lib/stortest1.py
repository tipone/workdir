#!/usr/bin/python
# Workdir Software -- 2017 kansukse@gmail.com
from buildbot.config import BuilderConfig
from buildbot.schedulers import forcesched, basic, timed, triggerable
from buildbot.plugins import *
from buildbot.steps import shell, trigger

class Builder:
	def __init__(self):
		self.buildername = "stortest1"
		self.workernames = ["bbmaster-worker"]
		self.workdir = "/BUILDBOT/workdir"
		self.masterdir = "/BUILDBOT/sandbox/master"
		self.tmpdir = "/BUILDBOT/tmp"
		self.scripts = "/BUILDBOT/workdir/bot/scripts"
		self.gitdir = "/BUILDBOT/git/storbox"
		self.repourl = "ssh://master:/git/storbox.git"
		self.branch='master'
	def _factory(self):
		self.factory = util.BuildFactory()		
		self.factory.addStep(steps.ShellCommand(command=["bash", "stortest1.sh"], workdir=self.scripts))
	def build(self):
		self._factory()
		builder = util.BuilderConfig(name=self.buildername,
			  workernames=self.workernames,
			  factory=self.factory)
		return builder
		
	def scheduler(self):
		
		scheduler = []
#		scheduler.append(basic.SingleBranchScheduler(
#									name=self.buildername + "-master",
#									change_filter=util.ChangeFilter(repository=self.repourl, branch=self.branch),
#									treeStableTimer=None,
#									builderNames=[self.buildername]))
		scheduler.append(forcesched.ForceScheduler(
									name=self.buildername + "-force",
									builderNames=[self.buildername]))

		scheduler.append(triggerable.Triggerable(
									name="%s-triggered"%self.buildername,
									builderNames=[self.buildername]))
		return scheduler

	def change(self):
		change = changes.GitPoller(
			self.repourl,
			workdir='gitpoller-workdir', 
			branch=self.branch,
			pollinterval=300)
		return change
	

if __name__ == "__main__":
	builder = Builder()
	print(builder.scheduler())
	print(builder.build())
