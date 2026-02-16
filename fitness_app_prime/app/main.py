import os
import sys
from pathlib import Path

from PySide6.QtCore import QUrl
from PySide6.QtGui import QIcon
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtWidgets import QApplication


def main():
    # ВАЖНО: переменные среды должны быть выставлены ДО создания QApplication,
    # иначе стиль Qt Quick Controls может не примениться.
    #
    # Platform-native стили (например, Windows) выдают предупреждения, если вы
    # кастомизируете background/contentItem у Controls. Выбираем "Basic".
    os.environ.setdefault("QT_QUICK_CONTROLS_STYLE", "Basic")

    # Логи импорта QML (можно убрать позже)
    os.environ.setdefault("QML_IMPORT_TRACE", "1")

    # Важно: Controls стабильнее с QApplication
    app = QApplication(sys.argv)

    base_dir = Path(__file__).resolve().parent
    qml_path = (base_dir / "ui" / "Main.qml").resolve()

    if not qml_path.exists():
        print(f"[FATAL] Main.qml not found: {qml_path}", file=sys.stderr)
        return 1

    engine = QQmlApplicationEngine()

    def on_warnings(warnings):
        for w in warnings:
            print("[QML WARNING]", w.toString(), file=sys.stderr)

    engine.warnings.connect(on_warnings)

    engine.load(QUrl.fromLocalFile(str(qml_path)))

    if not engine.rootObjects():
        print("[FATAL] QML rootObjects is empty. Window was not created.", file=sys.stderr)
        return 1

    return app.exec()


if __name__ == "__main__":
    raise SystemExit(main())
