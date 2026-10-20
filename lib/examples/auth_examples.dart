import 'package:flutter/material.dart';

import '../theme/kit_colors.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/fields/basic_fields.dart';
import '../widgets/kit_buttons.dart';

/// Disposition : où se trouve le formulaire et ce qui l'entoure.
enum AuthLayout { centered, splitRight, splitLeft, image, minimal }

/// Contenu du formulaire.
enum AuthScreen { login, register, forgot, otp, lock, social, accounts }

/// Présentation des connexions sociales (`SsoConfig` Angular).
enum SsoStyle { grid, stack, icons, brand }

class SsoConfig {
  const SsoConfig(this.style, this.providers, {this.top = false, this.verb});
  final SsoStyle style;
  final List<String> providers;
  final bool top;
  final String? verb;
}

class AuthVariant {
  const AuthVariant(this.layout, this.screen, [this.sso]);
  final AuthLayout layout;
  final AuthScreen screen;
  final SsoConfig? sso;
}

/// Les 11 variantes de `/examples/auth/:variant`.
const Map<String, AuthVariant> kAuthVariants = {
  'centered': AuthVariant(AuthLayout.centered, AuthScreen.login, SsoConfig(SsoStyle.icons, ['google', 'apple', 'microsoft', 'facebook', 'github', 'linkedin'])),
  'split-right': AuthVariant(AuthLayout.splitRight, AuthScreen.login, SsoConfig(SsoStyle.grid, ['google', 'microsoft'])),
  'split-left': AuthVariant(AuthLayout.splitLeft, AuthScreen.login, SsoConfig(SsoStyle.stack, ['google', 'apple', 'microsoft'], top: true, verb: 'Continuer avec')),
  'image': AuthVariant(AuthLayout.image, AuthScreen.login, SsoConfig(SsoStyle.brand, ['google', 'apple'], verb: 'Continuer avec')),
  'minimal': AuthVariant(AuthLayout.minimal, AuthScreen.login, SsoConfig(SsoStyle.stack, ['google', 'microsoft', 'github'], top: true, verb: 'Se connecter avec')),
  'register': AuthVariant(AuthLayout.splitRight, AuthScreen.register, SsoConfig(SsoStyle.grid, ['google', 'linkedin'], top: true)),
  'social': AuthVariant(AuthLayout.centered, AuthScreen.social, SsoConfig(SsoStyle.brand, ['google', 'apple', 'microsoft', 'facebook', 'github', 'linkedin'], verb: 'Continuer avec')),
  'accounts': AuthVariant(AuthLayout.minimal, AuthScreen.accounts),
  'forgot': AuthVariant(AuthLayout.centered, AuthScreen.forgot),
  'otp': AuthVariant(AuthLayout.centered, AuthScreen.otp),
  'lock': AuthVariant(AuthLayout.image, AuthScreen.lock),
};

const Map<String, String> kAuthLabels = {
  'centered': 'Connexion centrée', 'split-right': 'Connexion, panneau à gauche', 'split-left': 'Connexion, panneau à droite',
  'image': 'Connexion sur image', 'minimal': 'Connexion minimale', 'register': 'Inscription en 3 étapes',
  'social': 'Connexion sociale', 'accounts': 'Choix du compte', 'forgot': 'Mot de passe oublié',
  'otp': 'Code de vérification', 'lock': 'Session verrouillée',
};

const _providers = <String, (String, IconData, Color, Color)>{
  'google': ('Google', Icons.g_mobiledata, Colors.white, Color(0xFF1F1F1F)),
  'apple': ('Apple', Icons.apple, Colors.black, Colors.white),
  'microsoft': ('Microsoft', Icons.window, Color(0xFF2F2F2F), Colors.white),
  'facebook': ('Facebook', Icons.facebook, Color(0xFF1877F2), Colors.white),
  'github': ('GitHub', Icons.code, Color(0xFF24292F), Colors.white),
  'linkedin': ('LinkedIn', Icons.business_center, Color(0xFF0A66C2), Colors.white),
};

class AuthExample extends StatefulWidget {
  const AuthExample({super.key, required this.variant});
  final String variant;
  @override
  State<AuthExample> createState() => _AuthExampleState();
}

class _AuthExampleState extends State<AuthExample> {
  bool _busy = false, _done = false, _remember = true, _showPwd = false, _terms = false;
  String _error = '', _password = '', _email = 'jean.kouassi@example.com', _otp = '';
  int _step = 0, _account = -1;
  String _size = '11-50';

  AuthVariant get _v => kAuthVariants[widget.variant] ?? kAuthVariants['centered']!;

  Future<void> _submit([String Function()? check]) async {
    final err = check?.call() ?? '';
    setState(() => _error = err);
    if (err.isNotEmpty) return;
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() { _busy = false; _done = true; });
  }

  void _reset() => setState(() { _done = false; _password = ''; _otp = ''; _step = 0; _error = ''; _account = -1; });

  // ─── Briques ──────────────────────────────────────────────────────────────
  Widget _brand({bool light = false}) => Row(mainAxisSize: MainAxisSize.min, children: [
        ConstrainedBox(constraints: const BoxConstraints(maxWidth: 40, maxHeight: 28), child: Image.asset(light ? 'assets/images/logo-white.png' : 'assets/images/logo.png', fit: BoxFit.contain, errorBuilder: (_, _, _) => const Icon(Icons.inventory_2))),
        const SizedBox(width: Space.s2),
        Text('SC Storage', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: light ? Colors.white : null)),
      ]);

  Widget _title(String t, String sub, {bool center = false, IconData? icon}) => Column(
        crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(Space.s3),
              decoration: BoxDecoration(color: context.kc.primaryLight, borderRadius: BorderRadius.circular(Radii.lg)),
              child: Icon(icon, color: context.kc.primary, size: 28),
            ),
            const SizedBox(height: Space.s4),
          ],
          Text(t, textAlign: center ? TextAlign.center : TextAlign.start, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: Space.s2),
          Text(sub, textAlign: center ? TextAlign.center : TextAlign.start, style: TextStyle(color: context.kc.textSecondary)),
          const SizedBox(height: Space.s6),
        ],
      );

  Widget _errorBox() => _error.isEmpty
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(bottom: Space.s4),
          child: Container(
            padding: const EdgeInsets.all(Space.s3),
            decoration: BoxDecoration(color: context.kc.errorLight, borderRadius: BorderRadius.circular(Radii.md)),
            child: Row(children: [Icon(Icons.error_outline, color: context.kc.errorText), const SizedBox(width: Space.s2), Expanded(child: Text(_error, style: TextStyle(color: context.kc.errorText)))]),
          ),
        );

  Widget _or() => const Padding(padding: EdgeInsets.symmetric(vertical: Space.s4), child: LabeledDivider('ou'));

  Widget _sso(SsoConfig s) {
    Widget btn(String id, {bool expand = true}) {
      final p = _providers[id]!;
      final label = s.verb == null ? p.$1 : '${s.verb} ${p.$1}';
      if (s.style == SsoStyle.brand) {
        return SizedBox(
          height: 48,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: p.$3, foregroundColor: p.$4, side: p.$3 == Colors.white ? BorderSide(color: context.kc.border) : null),
            onPressed: () => _submit(),
            icon: Icon(p.$2),
            label: Text(label, overflow: TextOverflow.ellipsis),
          ),
        );
      }
      return SizedBox(height: 48, child: OutlinedButton.icon(onPressed: () => _submit(), icon: Icon(p.$2), label: Text(label, overflow: TextOverflow.ellipsis)));
    }

    switch (s.style) {
      case SsoStyle.icons:
        return Wrap(alignment: WrapAlignment.center, spacing: Space.s3, runSpacing: Space.s3, children: [
          for (final id in s.providers)
            IconButton.outlined(iconSize: 22, constraints: const BoxConstraints.tightFor(width: 48, height: 48), tooltip: _providers[id]!.$1, onPressed: () => _submit(), icon: Icon(_providers[id]!.$2)),
        ]);
      case SsoStyle.grid:
        return LayoutBuilder(builder: (context, box) {
          final w = box.maxWidth < 300 ? box.maxWidth : (box.maxWidth - Space.s3) / 2;
          return Wrap(spacing: Space.s3, runSpacing: Space.s3, children: [for (final id in s.providers) SizedBox(width: w, child: btn(id))]);
        });
      case SsoStyle.stack:
      case SsoStyle.brand:
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final id in s.providers) Padding(padding: const EdgeInsets.only(bottom: Space.s3), child: btn(id)),
        ]);
    }
  }

  Widget _link(String before, String link, VoidCallback onTap) => Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, children: [
        Text(before),
        TextButton(onPressed: onTap, child: Text(link, style: const TextStyle(fontWeight: FontWeight.w700))),
      ]);

  Widget _success(String title, String msg) => Column(children: [
        Icon(Icons.check_circle, size: 64, color: context.kc.success),
        const SizedBox(height: Space.s4),
        Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: Space.s2),
        Text(msg, textAlign: TextAlign.center, style: TextStyle(color: context.kc.textSecondary)),
        const SizedBox(height: Space.s6),
        KitButton(label: 'Recommencer la démo', icon: Icons.refresh, variant: KitButtonVariant.outline, onPressed: _reset),
      ]);

  Widget _passwordField({bool forgotLink = true}) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (forgotLink)
          Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: const Text('Mot de passe oublié ?'))),
        TextFormField(
          obscureText: !_showPwd,
          onChanged: (v) => _password = v,
          decoration: InputDecoration(
            labelText: 'Mot de passe',
            hintText: 'Essayez « demo »',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(tooltip: _showPwd ? 'Masquer' : 'Afficher', icon: Icon(_showPwd ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _showPwd = !_showPwd)),
          ),
        ),
      ]);

  /// Case à cocher + libellé cliquable (sans ListTile : les fonds colorés masqueraient l'encre).
  Widget _check(bool value, ValueChanged<bool> onChanged, String label) => Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.s2),
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.sm),
          onTap: () => onChanged(!value),
          child: Row(children: [Checkbox(value: value, onChanged: (v) => onChanged(v!)), const SizedBox(width: Space.s1), Expanded(child: Text(label))]),
        ),
      );

  // ─── Écrans ───────────────────────────────────────────────────────────────
  Widget _login() {
    if (_done) return _success('Connexion réussie', 'Bienvenue, Jean. Redirection vers votre espace…');
    final sso = _v.sso;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _title('Bon retour !', 'Connectez-vous pour accéder à votre espace.'),
      if (sso != null && sso.top) ...[_sso(sso), _or()],
      _errorBox(),
      TextFormField(initialValue: _email, onChanged: (v) => _email = v, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Adresse e-mail', prefixIcon: Icon(Icons.email))),
      const SizedBox(height: Space.s2),
      _passwordField(),
      _check(_remember, (v) => setState(() => _remember = v), 'Rester connecté'),
      const SizedBox(height: Space.s2),
      KitButton(label: 'Se connecter', expand: true, size: KitButtonSize.large, loading: _busy, onPressed: () => _submit(() => !_email.contains('@') ? 'Adresse e-mail invalide.' : _password.length < 4 ? 'Mot de passe incorrect. Essayez « demo ».' : '')),
      if (sso != null && !sso.top) ...[_or(), _sso(sso)],
      const SizedBox(height: Space.s4),
      _link('Pas encore de compte ? ', 'Créer un compte', () {}),
    ]);
  }

  Widget _register() {
    if (_done) return _success('Compte créé', 'Votre essai gratuit de 30 jours commence maintenant.');
    const steps = ['Compte', 'Sécurité', 'Organisation'];
    final body = switch (_step) {
      0 => Column(children: [
          if (_v.sso != null) ...[_sso(_v.sso!), _or()],
          const ExRow2([KitTextField(label: 'Prénom', initialValue: 'Jean'), KitTextField(label: 'Nom', initialValue: 'Kouassi')]),
          const SizedBox(height: Space.s4),
          const KitTextField(label: 'E-mail professionnel', initialValue: 'jean.kouassi@scstorage.ci', icon: Icons.alternate_email),
        ]),
      1 => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const PasswordField(),
          _check(_terms, (v) => setState(() => _terms = v), 'J’accepte les conditions d’utilisation et la politique de confidentialité.'),
        ]),
      _ => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const KitTextField(label: 'Organisation', initialValue: 'SC Storage', icon: Icons.business),
          const SizedBox(height: Space.s4),
          Text('Taille de l’équipe', style: TextStyle(fontWeight: FontWeight.w600, color: context.kc.textSecondary)),
          const SizedBox(height: Space.s2),
          Wrap(spacing: Space.s2, runSpacing: Space.s2, children: [
            for (final s in ['1-10', '11-50', '51-200', '200+']) ChoiceChip(label: Text(s), selected: _size == s, onSelected: (_) => setState(() => _size = s)),
          ]),
        ]),
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _title('Créer votre compte', 'Essai gratuit de 30 jours, sans carte bancaire.'),
      Wrap(spacing: Space.s2, runSpacing: Space.s2, children: [
        for (var i = 0; i < 3; i++) StatusBadge('${i + 1}. ${steps[i]}', uppercase: false, tone: i == _step ? KitTone.primary : i < _step ? KitTone.success : KitTone.neutral, icon: i < _step ? Icons.check : null),
      ]),
      const SizedBox(height: Space.s6),
      _errorBox(),
      body,
      const SizedBox(height: Space.s6),
      Row(children: [
        if (_step > 0) ...[KitButton(label: 'Retour', variant: KitButtonVariant.ghost, onPressed: () => setState(() => _step--)), const SizedBox(width: Space.s2)],
        Expanded(
          child: KitButton(
            label: _step == 2 ? 'Créer un compte' : 'Continuer',
            expand: true,
            loading: _busy,
            onPressed: () {
              if (_step == 1 && !_terms) return setState(() => _error = 'Acceptez les conditions pour continuer.');
              _error = '';
              _step == 2 ? _submit() : setState(() => _step++);
            },
          ),
        ),
      ]),
      const SizedBox(height: Space.s4),
      _link('Déjà inscrit ? ', 'Se connecter', () {}),
    ]);
  }

  Widget _forgot() {
    if (_done) {
      return Column(children: [
        _title('Vérifiez votre boîte mail', 'Un lien de réinitialisation a été envoyé à $_email. Il expire dans 30 minutes.', center: true, icon: Icons.mark_email_read_outlined),
        KitButton(label: 'Retour à la connexion', icon: Icons.arrow_back, variant: KitButtonVariant.outline, onPressed: _reset),
      ]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _title('Mot de passe oublié ?', 'Saisissez l’adresse e-mail de votre compte : nous vous enverrons un lien de réinitialisation.', center: true, icon: Icons.lock_reset),
      _errorBox(),
      TextFormField(initialValue: _email, onChanged: (v) => _email = v, decoration: const InputDecoration(labelText: 'Adresse e-mail', prefixIcon: Icon(Icons.email))),
      const SizedBox(height: Space.s6),
      KitButton(label: 'Envoyer le lien', expand: true, size: KitButtonSize.large, loading: _busy, onPressed: () => _submit(() => !_email.contains('@') ? 'Saisissez l’adresse e-mail de votre compte.' : '')),
      const SizedBox(height: Space.s2),
      TextButton.icon(onPressed: () {}, icon: const Icon(Icons.arrow_back), label: const Text('Retour à la connexion')),
    ]);
  }

  Widget _otpScreen() {
    if (_done) return _success('Connexion réussie', 'Votre identité est vérifiée.');
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _title('Vérification en deux étapes', 'Saisissez le code à 6 chiffres envoyé au +225 07 •• •• 56. (Code de démo : 123456)', center: true, icon: Icons.sms_outlined),
      Center(child: OtpInput(error: _error.isNotEmpty, onChanged: (v) => _otp = v, onCompleted: (v) => _otp = v)),
      if (_error.isNotEmpty) Padding(padding: const EdgeInsets.only(top: Space.s2), child: Text(_error, textAlign: TextAlign.center, style: TextStyle(color: context.kc.errorText))),
      const SizedBox(height: Space.s6),
      KitButton(label: 'Vérifier', expand: true, size: KitButtonSize.large, loading: _busy, onPressed: () => _submit(() => _otp == '123456' ? '' : 'Code incorrect, réessayez.')),
      const SizedBox(height: Space.s4),
      Text('Renvoyer le code dans 29 s', textAlign: TextAlign.center, style: TextStyle(color: context.kc.textSecondary)),
    ]);
  }

  Widget _lock() {
    if (_done) return _success('Session déverrouillée', 'Vous reprenez là où vous en étiez.');
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Center(child: KitAvatar(name: 'Jean Kouassi', size: 72)),
      const SizedBox(height: Space.s4),
      _title('Session verrouillée', 'Jean Kouassi · saisissez votre mot de passe pour continuer.', center: true),
      _errorBox(),
      _passwordField(forgotLink: false),
      const SizedBox(height: Space.s6),
      KitButton(label: 'Déverrouiller', icon: Icons.lock_open, expand: true, size: KitButtonSize.large, loading: _busy, onPressed: () => _submit(() => _password.length < 4 ? 'Mot de passe incorrect.' : '')),
      const SizedBox(height: Space.s2),
      _link('Pas vous ? ', 'Changer de compte', () {}),
    ]);
  }

  Widget _social() {
    if (_done) return _success('Connexion réussie', 'Bienvenue, Jean.');
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _title('Bienvenue', 'Connectez-vous en un clic avec un compte que vous utilisez déjà.', center: true),
      _sso(_v.sso!),
      _or(),
      KitButton(label: 'Continuer avec une adresse e-mail', icon: Icons.email_outlined, variant: KitButtonVariant.outline, expand: true, onPressed: () {}),
      const SizedBox(height: Space.s4),
      Text('En continuant, vous acceptez les conditions d’utilisation et la politique de confidentialité.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: context.kc.textMuted)),
    ]);
  }

  Widget _accounts() {
    if (_done) return _success('Connexion réussie', 'Connecté en tant que ${_account == 1 ? 'j.kouassi@scstorage.ci' : 'jean.kouassi@gmail.com'}.');
    const accounts = [('Jean Kouassi', 'jean.kouassi@gmail.com', false), ('Jean Kouassi', 'j.kouassi@scstorage.ci', true)];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _title('Choisissez un compte', 'pour continuer vers SC Storage', center: true),
      for (var i = 0; i < accounts.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: Space.s2),
          child: KitCard(
            onTap: () { _account = i; _submit(); },
            child: Row(children: [
              KitAvatar(name: accounts[i].$1, tone: i == 0 ? KitTone.info : KitTone.purple),
              const SizedBox(width: Space.s3),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Flexible(child: Text(accounts[i].$1, style: const TextStyle(fontWeight: FontWeight.w600))), if (accounts[i].$3) ...[const SizedBox(width: Space.s2), const StatusBadge('Pro', tone: KitTone.purple, uppercase: false)]]),
                Text(accounts[i].$2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: context.kc.textMuted)),
              ])),
              if (_busy && _account == i) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) else Icon(Icons.chevron_right, color: context.kc.textMuted),
            ]),
          ),
        ),
      KitButton(label: 'Utiliser un autre compte', icon: Icons.person_add_alt, variant: KitButtonVariant.ghost, expand: true, onPressed: () {}),
    ]);
  }

  Widget _form() => switch (_v.screen) {
        AuthScreen.login => _login(),
        AuthScreen.register => _register(),
        AuthScreen.forgot => _forgot(),
        AuthScreen.otp => _otpScreen(),
        AuthScreen.lock => _lock(),
        AuthScreen.social => _social(),
        AuthScreen.accounts => _accounts(),
      };

  Widget _footer() => Padding(
        padding: const EdgeInsets.only(top: Space.s6),
        child: Text('© 2026 SC Storage · Confidentialité · Conditions', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: context.kc.textMuted)),
      );

  /// Panneau de marque des dispositions « split » (masqué sous 1024 px).
  Widget _brandPanel() {
    const stats = [('2 400+', 'entreprises'), ('98 %', 'de satisfaction'), ('24/7', 'support')];
    const perks = [(Icons.bolt, 'Mise en route en 5 minutes'), (Icons.devices, 'Accessible partout, même hors ligne'), (Icons.lock, 'Données chiffrées et sauvegardées')];
    return Container(
      padding: const EdgeInsets.all(Space.s10),
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [context.kc.primary, Color.lerp(context.kc.primary, Colors.black, .45)!])),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: Colors.white),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _brand(light: true),
          const Spacer(),
          const Text('Pilotez toute votre activité depuis un seul espace.', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2)),
          const SizedBox(height: Space.s6),
          for (final p in perks) Padding(padding: const EdgeInsets.only(bottom: Space.s3), child: Row(children: [Icon(p.$1, color: Colors.white70), const SizedBox(width: Space.s3), Expanded(child: Text(p.$2))])),
          const SizedBox(height: Space.s6),
          Wrap(spacing: Space.s8, runSpacing: Space.s4, children: [
            for (final s in stats) Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.$1, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)), Text(s.$2, style: const TextStyle(color: Colors.white70))]),
          ]),
          const Spacer(),
          const Text('« Nous avons divisé par deux le temps de clôture mensuelle. »', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white)),
          const SizedBox(height: Space.s2),
          const Text('Aya Koné · Directrice des opérations, Sotra Logistique', style: TextStyle(color: Colors.white70, fontSize: 13)),
        ]),
      ),
    );
  }

  Widget _scroll(Widget child, {double maxWidth = 440, EdgeInsets? padding}) => LayoutBuilder(builder: (context, box) {
        final pad = padding ?? EdgeInsets.symmetric(horizontal: box.maxWidth < Breakpoints.tablet ? Space.s5 : Space.s8, vertical: Space.s8);
        return SingleChildScrollView(
          padding: pad,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: (box.maxHeight - pad.vertical).clamp(0, double.infinity)),
            child: Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child)),
          ),
        );
      });

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final content = Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [_form(), _footer()]);
    final back = Padding(padding: const EdgeInsets.all(Space.s2), child: IconButton.filledTonal(tooltip: 'Retour', icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).maybePop()));

    final Widget body = switch (_v.layout) {
      AuthLayout.centered => Container(
          color: c.bg,
          child: _scroll(Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Center(child: _brand()),
            const SizedBox(height: Space.s6),
            LayoutBuilder(builder: (context, box) => box.maxWidth < Breakpoints.sm
                ? content
                : KitCard(padding: const EdgeInsets.all(Space.s8), shadow: true, child: content)),
          ])),
        ),
      AuthLayout.minimal => Container(color: c.card, child: _scroll(Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [Center(child: _brand()), const SizedBox(height: Space.s8), content]), maxWidth: 380)),
      AuthLayout.image => Stack(fit: StackFit.expand, children: [
          Image.asset('assets/images/bg.jpg', fit: BoxFit.cover, color: Colors.black38, colorBlendMode: BlendMode.darken, errorBuilder: (_, _, _) => Container(color: c.primary)),
          LayoutBuilder(builder: (context, box) {
            final wide = box.maxWidth >= Breakpoints.xl;
            final card = KitCard(padding: EdgeInsets.all(box.maxWidth < Breakpoints.sm ? Space.s5 : Space.s8), shadow: true, child: content);
            return Row(children: [
              if (wide)
                Expanded(child: Padding(padding: const EdgeInsets.all(Space.s10), child: Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start, children: [_brand(light: true), const SizedBox(height: Space.s2), const Text('Entrepôt de Vridi · Abidjan', style: TextStyle(color: Colors.white70))]))),
              Expanded(child: _scroll(card, padding: EdgeInsets.all(box.maxWidth < Breakpoints.sm ? Space.s3 : Space.s8))),
            ]);
          }),
        ]),
      AuthLayout.splitRight || AuthLayout.splitLeft => LayoutBuilder(builder: (context, box) {
          final form = Container(color: c.bg, child: _scroll(Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [Align(alignment: Alignment.centerLeft, child: _brand()), const SizedBox(height: Space.s8), content])));
          if (box.maxWidth < Breakpoints.xl) return form;
          final panel = Expanded(child: _brandPanel());
          return Row(children: _v.layout == AuthLayout.splitRight ? [panel, Expanded(child: form)] : [Expanded(child: form), panel]);
        }),
    };

    return Scaffold(body: Stack(children: [Positioned.fill(child: body), Positioned(top: 0, left: 0, child: SafeArea(child: back))]));
  }
}

/// Deux champs côte à côte (≥ 360 px), sinon empilés.
class ExRow2 extends StatelessWidget {
  const ExRow2(this.children, {super.key});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        if (box.maxWidth < 360) return Column(children: [children[0], const SizedBox(height: Space.s4), children[1]]);
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: children[0]), const SizedBox(width: Space.s3), Expanded(child: children[1])]);
      });
}
