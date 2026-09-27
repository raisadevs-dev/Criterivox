import 'package:flutter/material.dart';
class TarkisPresentation {
  static const characterId='tarkis'; static const role='Hypothesis Exploration';
  static const chatPrompts=<String>['Generate alternatives.','Compare hypotheses.','Find supporting evidence.','Find conflicting evidence.','Explore a counterfactual.','Show what remains unestablished.','Trace the hypothesis basis.'];
  static const capabilities=<TarkisCapability>[
    TarkisCapability('generation','HYPOTHESIS GENERATION','Generate bounded candidate hypotheses from the current reasoning context.',Icons.lightbulb_outline),
    TarkisCapability('comparison','HYPOTHESIS COMPARISON','Compare candidates against supplied context without declaring external truth.',Icons.compare_outlined),
    TarkisCapability('support','SUPPORT REVIEW','Identify supplied-context support for candidates.',Icons.add_task_outlined),
    TarkisCapability('conflict','CONFLICT REVIEW','Identify supplied-context conflicts for candidates.',Icons.remove_circle_outline),
    TarkisCapability('counterfactual','COUNTERFACTUAL EXPLORATION','Explore alternatives without presenting them as facts.',Icons.alt_route_outlined),
    TarkisCapability('basis','HYPOTHESIS BASIS','Trace candidate hypotheses to their reasoning artifact.',Icons.account_tree_outlined),
  ];
}
class TarkisCapability { final String id,label,description; final IconData icon; const TarkisCapability(this.id,this.label,this.description,this.icon); }
