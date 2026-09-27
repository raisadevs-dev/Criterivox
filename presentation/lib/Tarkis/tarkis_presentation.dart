import 'package:flutter/material.dart';
class TarkisPresentation {
  static const characterId='tarkis'; static const role='Hypothesis Exploration';
  static const chatPrompts=<String>['Generate bounded alternatives.','Compare the hypotheses.','Explore a counterfactual.','Inspect the active branch.','Show what is unsupported.','Revise the exploration after a challenge.'];
  static const capabilities=<TarkisCapability>[
    TarkisCapability('hypotheses','HYPOTHESIS VARIATION','Generate explicit alternatives from supplied material.',Icons.alt_route_outlined),
    TarkisCapability('comparison','HYPOTHESIS COMPARISON','Compare candidate hypotheses without declaring external truth.',Icons.compare_arrows_outlined),
    TarkisCapability('counterfactual','BOUNDED COUNTERFACTUAL','Explore a supplied causal intervention without inventing effects.',Icons.change_history_outlined),
    TarkisCapability('branches','BRANCH EXPLORATION','Track alternative reasoning branches and their artifacts.',Icons.account_tree_outlined),
    TarkisCapability('challenge','CHALLENGE REVISION','Continue exploration after a human challenge.',Icons.edit_note_outlined),
  ];
}
class TarkisCapability { final String id,label,description; final IconData icon; const TarkisCapability(this.id,this.label,this.description,this.icon); }
