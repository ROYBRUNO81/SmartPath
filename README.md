SmartPath is a student productivity app that helps you organize classes, tasks, exams, and campus life in one place. It combines a clean calendar, a focused task list, and a simple profile to keep academic planning straightforward and stress‑free.

## Features

- Calendar Views
  - Day, Week, and Month layouts with simple navigation
  - Real‑time indicator line showing “now” in Day view
  - Category filters (Classes, Exams, Tasks, Holidays, Interviews, Coffee Chats)
  - “Today” button and previous/next arrows for quick navigation

- Tasks
  - Pending tasks card on Profile with quick access to the next 7 days
  - Grouped list by date with per‑day counts on the right
  - Each task shows title and due time; empty days show “No tasks”
  - Task fields: Title, Description, Type (Assignment, Reminder, Essay), Repeat (Once, Every week), Due Date, Time

- Events
  - Upcoming events card with a 7‑day view
  - Event fields: Title, Date, Start Time, End Time, Type (Class, Interview, Coffee chat, Campus event, Exam, Holiday), Repeat (Once, Every week)

- Profile
  - Student info (ID, Name, Year, Term, GPA) with photo
  - Edit profile and image picker

- Catalog (prototype)
  - Course detail scraping helper using SwiftSoup to prefill course info (code/title/description/credit/prereqs)

## Design System

- Background: #F5F7F3 (very light mint)
- Primary (Accent): #3D8B7D (teal)
- Secondary (On‑dark Accent): #2C5F54

These colors are used across navigation controls, selection states, and cards for a cohesive look.

## Tech Stack

- SwiftUI for UI
- SwiftData for local models (Student, Major, Course, Schedule)
- SwiftSoup for catalog scraping (proof of concept)

## Project Structure

- Models: `Student`, `Major`, `Course`, `Schedule`, `TaskItem`, `EventItem`
- Views: `ContentView`, `PlannerCalendarView` (Day/Week/Month), `TaskListView`, `EventListView`, `ProfileView`, `EditProfileView`
- ViewModel: `CalendarViewModel`, `ProfileViewModel`, `HomeViewModel`, `PlanViewModel`, `CatalogViewModel`
- Services: `DataService` (SwiftData container), `CatalogService`, `ImagePicker`

## Getting Started (Xcode 16 / iOS 18)

1. Open `SmartPath.xcodeproj` in Xcode.
2. Build and run on iOS Simulator or device.
3. From the Profile tab, try “Pending Tasks” and “Upcoming Events” to preview sample data.
4. Open the Calendar tab to switch Day/Week/Month views and toggle filters from the side menu.

## Roadmap

- Persist tasks/events with SwiftData and add CRUD screens
- Render tasks and events directly on Day/Week/Month canvases
- Import schedules from images/ICS
- Notifications and smart reminders

## Notes

This repository currently uses sample data for tasks and events to showcase UX and flows while the persistence layer is finalized.
