BEGIN {
  Goal["do_work"]
  Goal["document_processed"]
  Goal["document_downloaded"]

  GoalParamsCnt["document_processed"] = 1
  GoalParams   ["document_processed",0] = "F"

  GoalParamsCnt["document_downloaded"] = 1
  GoalParams   ["document_downloaded",0] = "F1"

  DependenciesCnt     ["do_work"] = 2

  Dependencies        ["do_work",0] = "document_processed"
  DependenciesArgsCnt ["do_work",0] = 1
  DependenciesArgs    ["do_work",0,0] = "file1"
  DependenciesArgsType["do_work",0,0] = "string"

  Dependencies        ["do_work",1] = "document_processed"
  DependenciesArgsCnt ["do_work",1] = 1
  DependenciesArgs    ["do_work",1,0] = "file 2"
  DependenciesArgsType["do_work",1,0] = "string"

  DependenciesCnt     ["document_processed"] = 1
  Dependencies        ["document_processed",0] = "document_downloaded"
  DependenciesArgsCnt ["document_processed",0] = 1
  DependenciesArgs    ["document_processed",0,0] = "F"
  DependenciesArgsType["document_processed",0,0] = "var"

  # === what we have ===
  #
  # - document_processed @params F
  #   - document_downloaded @args F
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
  #   - document_processed@'file 2'
  #     - document_downloaded@'file 2'

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
  for (i=0; i < DependenciesCnt[goal]; i++) {
    printDepsTree(Dependencies[goal,i],ind+1)
  }
}

