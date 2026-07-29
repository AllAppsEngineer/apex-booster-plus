# RELEASE-HARDENING-U1
#
# Este projeto depende primariamente de tres camadas de regras que ja sao
# aplicadas automaticamente pelo Android Gradle Plugin e pelo Flutter Gradle
# Plugin, nesta ordem, sem qualquer configuracao manual:
#
#   1. proguard-android-optimize.txt — regras padrao do AGP (Parcelable,
#      Serializable, enums, componentes do Manifest, etc.).
#   2. flutter_proguard_rules.pro — bundlado no SDK do Flutter (dontwarn
#      android.**/io.flutter.plugin.**, keep estreito para
#      implementacoes de FlutterPlugin).
#   3. consumer-rules.pro embutidas nos AARs de terceiros (Play Billing,
#      androidx.media3, plugins Flutter oficiais como image_picker,
#      share_plus, video_player, path_provider, shared_preferences).
#
# Nenhuma regra deste arquivo deve ser adicionada de forma especulativa.
# Toda regra "-keep" futura DEVE vir acompanhada, em comentario, de:
#   - a falha reproduzida em build release (stack trace de
#     ClassNotFoundException, NoSuchMethodError, falha de MethodChannel etc.);
#   - o escopo minimo necessario (classe/membro especifico — nunca
#     "-keep class ** { *; }" ou supressao global de warnings).
#
# Este arquivo comeca vazio de propósito. Se ele permanecer vazio, isso
# significa que as tres camadas acima continuam suficientes.
