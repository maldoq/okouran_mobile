/// Montants proposés en raccourci sur l'écran Recharger (FCFA).
/// 1 000, 2 000 et 5 000 F sont ceux du cahier des charges.
const List<int> rechargeAmounts = [1000, 2000, 5000, 10000, 20000];

/// Montant présélectionné à l'ouverture de l'écran.
const int defaultRechargeAmount = 5000;

/// Bornes du montant libre (« Autre »).
const int minRechargeAmount = 500;
const int maxRechargeAmount = 100000;