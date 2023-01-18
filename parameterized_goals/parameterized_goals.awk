BEGIN {
  Goal["do_work"]
  Goal["document_processed"]
  Goal["document_downloaded"]

  GoalParamsCnt["document_processed"] = 1
  GoalParams   ["document_processed",0] = "F"

  GoalParamsCnt["document_downloaded"] = 1
  GoalParams   ["document_downloaded",0] = "F1"

  DependencyCnt     ["do_work"] = 2

  Dependency        ["do_work",0] = "document_processed"
  DependencyArgsCnt ["do_work",0] = 1
  DependencyArgs    ["do_work",0,0] = "file1"
  DependencyArgsType["do_work",0,0] = "string"

  Dependency        ["do_work",1] = "document_processed"
  DependencyArgsCnt ["do_work",1] = 1
  DependencyArgs    ["do_work",1,0] = "file 2"
  DependencyArgsType["do_work",1,0] = "string"

  DependencyCnt     ["document_processed"] = 2

  Dependency        ["document_processed",0] = "document_downloaded"
  DependencyArgsCnt ["document_processed",0] = 1
  DependencyArgs    ["document_processed",0,0] = "F"
  DependencyArgsType["document_processed",0,0] = "var"

  Dependency        ["document_processed",1] = "document_downloaded"
  DependencyArgsCnt ["document_processed",1] = 1
  DependencyArgs    ["document_processed",1,0] = "file333"
  DependencyArgsType["document_processed",1,0] = "string"

  # === what we have ===
  #
  # - document_processed @params F
  #   - document_downloaded @args F
  #   - document_downloaded @args 'file333'
  #
  # - document_downloaded @params F1
  #
  # - do_work
  #   - document_processed @args 'file1'
  #   - document_processed @args 'file 2'
  #
  # === what we need ===
  #
  # - document_processed@file1
  # - document_downloaded@file1
  # - document_processed@'file 2'
  # - document_downloaded@'file 2'
  # - do_work
  #   - document_processed@file1
  #     - document_downloaded@file1
  #     - document_downloaded@file3
  #   - document_processed@'file 2'
  #     - document_downloaded@'file 2'
  #     - document_downloaded@file3

  print "BEFORE:"
  printDepsTree("do_work")

  instantiate("do_work")

  print "AFTER:"
  printDepsTree("do_work")
}

function panic(s){ print s; exit 1 }
function indent(ind) {
  printf "%" ind*2 "s", ""
}
function printDepsTree(goal,ind,   i) {
  if (!(goal in Goal)) { panic("unknown goal: " goal) }
  indent(ind)
  print goal
  for (i=0; i < DependencyCnt[goal]; i++) {
    printDepsTree(Dependency[goal,i],ind+1)
  }
}
function renderArgs(args,   s,k) {
  s = ""
  for (k in args) {
    s = s k "=>" args[k] " "
  }
  return s
}
#
# args: { F => "file1" }
#
function instantiate(goal,args,newArgs,   i,j,depArg,depArgType,dep,goalNameInstantiated) { # -> goalNameInstantiated
  print ">instantiating " goal " { " renderArgs(args) "} ..."

  if (!(goal in Goal)) { panic("unknown goal: " goal) }

  Goal[goalNameInstantiated = instantiateGoalName(goal, args)]
  DependencyCnt[goalNameInstantiated] = DependencyCnt[goal]

  for (i=0; i < DependencyCnt[goal]; i++) {
    dep = Dependency[goal,i]

    if (DependencyArgsCnt[goal,i] != GoalParamsCnt[dep]) { panic("wrong args count") }

    for (j=0; j<DependencyArgsCnt[goal,i]; j++) {
      depArg     = DependencyArgs    [goal,i,j]
      depArgType = DependencyArgsType[goal,i,j]

      newArgs[GoalParams[dep,j]] = \
        depArgType == "string" ? \
          depArg : \
          depArgType == "var" ? \
            args[depArg] : \
            panic("wrong depArgType: " depArgType)
    }

    Dependency[goalNameInstantiated,i] = instantiate(dep,newArgs)
  }

  return goalNameInstantiated
}
function instantiateGoalName(goal, args,   res){
  if (GoalParamsCnt[goal] == 0) { return goal }
  res = goal
  for (i=0; i<GoalParamsCnt[goal]; i++) {
    res = res "@" args[GoalParams[goal,i]] # TODO fail if arg is not present in args?
    # TODO escape name with space
  }
  print "@@ " res
  return res
}

