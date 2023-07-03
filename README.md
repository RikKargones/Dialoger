# Dialoger
 
Небольшая разработка отдельного инструмента для Godot Engine.

Dialoger - иструмент для сценариста, позволящий ему без использования движка создовать диалоги в упрощенном виде.

Выходящий ресурс - это БД диалогов + внешние ресурсы (текстуры, шрифты) + два скрипта на GDScript. За исключением подключения нужных сигналов к скриптам в проекте, более ничего не требуется от программиста для полноценного использования этих продуктов.

На данный момент:
---
Созданно:
---
- Базовый менеджер созданных проектов.
- Базовый редактор/менеджер шрифтов.
- Редактор/менеджер локолизаций.
- Редактор/менеджер глобальных переменных диалогов (поддерживаются типы как bool, int, string и создание кастомных сигналов для собственных нужд).
- Редактор/менеджер персон (персоны - это действующие лица в диалоге; к ним привязываются текстуры-эмоции и кореляция шрифт-имя-язык).
- Графовый редактор/менеджер диалогов (реплики персон, ветвления, выборы ответных реплик, изменения переменных; поддерживается цикличность диалогов, запуск кастомных сигналов; есть возможность сравнинить текущую и выбранную локализации проекта для перевода/проверки на ошибки).
- Базовый предпросмотр созданного в редакторе диалогов, использующий экспортированные ресурсы в работе.
- Базовое сохранение проекта/экспорта готовых ресурсов. Сохранение и экспорт производятся в отдельном потоке для предотвращения зависания программы.

Планируемые исправления/улучшения:
---
- Переработка внутренней БД для уменьшения проблем с внутренней синхронизацией редактируемых ресурсов.
- Изучение вопроса возможности работы с встроенным разделом локализаций в Godot из кода ПО.
- Рабочие настройки редактируемого проекта.
- Улучшение/доработка менеджера проектов. Возможность сортировки сохраненных проектов по определенным критериям.
- Добавление в редактор шрифтов настроек для межстроковых интервалов/межсимвольных интервалов/переключения параметра "filter" и т.п.
- Оптимизация ПО и исправление мелких багов.

В дальнейших планах по разработке:
---
- Возможность добавить анимированные текстуры к персоне, настроить условия их срабатывания.
- Редактируемая форма предпросмотра (с возможностью экспорта в проект на движке) или возможность в проект программы подгрузить свою собственную форму, сделанную в Godot по определенным правилам.
- Собственный редактор графов для диалогового редактора.
- Анимации в интерфейсе ПО.
