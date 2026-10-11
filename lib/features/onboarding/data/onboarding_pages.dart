import '../../../core/constants/app_constants.dart';
import '../domain/onboarding_page.dart';

/// Les 3 pages d'onboarding (données statiques).
///
/// Elles regroupent les 5 messages de la maquette :
///   page 1 = garder un œil + suivre partout
///   page 2 = être alerté avant la coupure (écran détaillé de la maquette)
///   page 3 = anticiper + recharger à distance quand c'est possible
const List<OnboardingPage> onboardingPages = [
  OnboardingPage(
    image: AppAssets.onboardingMeter,
    imageAlignment: 0, // garde le compteur (gauche) et la personne (droite)
    visual: OnboardingVisual.meter,
    caption: 'VOTRE COMPTEUR, DANS VOTRE POCHE',
    title: 'Votre crédit,\nlisible en jours.',
    description:
        'Fini les kWh difficiles à interpréter : O\'kouran traduit votre solde '
        'en temps restant, depuis chez vous comme à distance.',
  ),
  OnboardingPage(
    image: AppAssets.onboardingAlert,
    imageAlignment: -.48, // 26 % horizontal, comme la maquette
    visual: OnboardingVisual.alert,
    caption: 'MÊME LOIN DE VOTRE COMPTEUR',
    title: 'Recevez une alerte\navant la coupure.',
    description:
        'Le bip du compteur ne s\'entend que devant le compteur. O\'kouran vous '
        'prévient sur votre téléphone : au bureau, en cours, en voyage.',
  ),
  OnboardingPage(
    image: AppAssets.onboardingRecharge,
    imageAlignment: 0,
    visual: OnboardingVisual.recharge,
    caption: 'ANTICIPER PLUTÔT QUE SUBIR',
    title: 'Anticipez,\nrechargez à temps.',
    description:
        'Une estimation de l\'heure de coupure, des scénarios de consommation, '
        'et la recharge à distance lorsque cela est possible.',
  ),
];