Map<String, String> schemas = {
  "Hospital": """datasource db {
    provider = "postgresql"
    url      = env("DATABASE_URL")
  }

  model Doctor {
    id            Int           @id @default(autoincrement())
    createdAt     DateTime      @default(now())
    updatedAt     DateTime      @updatedAt
    name          String
    specialization String
    email         String        @unique
    phoneNumber   String?
    appointments  Appointment[]
  }

  model Patient {
    id            Int           @id @default(autoincrement())
    createdAt     DateTime      @default(now())
    updatedAt     DateTime      @updatedAt
    name          String
    email         String        @unique
    phoneNumber   String?
    appointments  Appointment[]
    medicalRecord MedicalRecord?
  }

  model Appointment {
    id             Int           @id @default(autoincrement())
    createdAt      DateTime      @default(now())
    updatedAt      DateTime      @updatedAt
    appointmentDate DateTime
    doctor         Doctor        @relation(fields: [doctorId], references: [id])
    doctorId       Int
    patient        Patient       @relation(fields: [patientId], references: [id])
    patientId      Int
    status         AppointmentStatus
  }

  enum AppointmentStatus {
    Scheduled
    Confirmed
    Cancelled
  }

  model Ward {
    id           Int      @id @default(autoincrement())
    createdAt    DateTime @default(now())
    updatedAt    DateTime @updatedAt
    name         String
    capacity     Int
    beds         Bed[]
  }

  model Bed {
    id           Int           @id @default(autoincrement())
    createdAt    DateTime      @default(now())
    updatedAt    DateTime      @updatedAt
    ward         Ward          @relation(fields: [wardId], references: [id])
    wardId       Int
    occupied     Boolean       @default(false)
    patient      Patient?      @relation(fields: [patientId], references: [id])
    patientId    Int?
  }

  model MedicalRecord {
    id           Int           @id @default(autoincrement())
    createdAt    DateTime      @default(now())
    updatedAt    DateTime      @updatedAt
    patient      Patient       @relation(fields: [patientId], references: [id])
    patientId    Int
    diagnosis    String
    treatment    String
    prescriptions Prescription[]
  }

  model Prescription {
    id              Int            @id @default(autoincrement())
    createdAt       DateTime       @default(now())
    updatedAt       DateTime       @updatedAt
    medicalRecord   MedicalRecord  @relation(fields: [medicalRecordId], references: [id])
    medicalRecordId Int
    medication      String
    dosage          String
    frequency       String
  }

  model Payment {
    id              Int           @id @default(autoincrement())
    createdAt       DateTime      @default(now())
    updatedAt       DateTime      @updatedAt
    patient         Patient       @relation(fields: [patientId], references: [id])
    patientId       Int
    amount          Float
    paymentMethod   String
    date            DateTime
  }
  """,
  "Hotel": """datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model Room {
  id           Int      @id @default(autoincrement())
  createdAt    DateTime @default(now())
  updatedAt    DateTime @updatedAt
  number       String
  type         RoomType
  capacity     Int
  pricePerNight Float
  bookings     Booking[]
}

enum RoomType {
  Single
  Double
  Suite
}

model Guest {
  id           Int      @id @default(autoincrement())
  createdAt    DateTime @default(now())
  updatedAt    DateTime @updatedAt
  firstName    String
  lastName     String
  email        String   @unique
  phoneNumber  String?
  reservations Reservation[]
}

model Booking {
  id           Int       @id @default(autoincrement())
  createdAt    DateTime  @default(now())
  updatedAt    DateTime  @updatedAt
  checkInDate  DateTime
  checkOutDate DateTime
  room         Room      @relation(fields: [roomId], references: [id])
  roomId       Int
  guest        Guest     @relation(fields: [guestId], references: [id])
  guestId      Int
  status       BookingStatus
  payments     Payment[]
}

enum BookingStatus {
  Booked
  CheckedIn
  CheckedOut
  Cancelled
}

model Payment {
  id              Int       @id @default(autoincrement())
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt
  booking         Booking   @relation(fields: [bookingId], references: [id])
  bookingId       Int
  amount          Float
  paymentMethod   String
  date            DateTime
}

model Reservation {
  id           Int       @id @default(autoincrement())
  createdAt    DateTime  @default(now())
  updatedAt    DateTime  @updatedAt
  checkInDate  DateTime
  checkOutDate DateTime
  room         Room      @relation(fields: [roomId], references: [id])
  roomId       Int
  guest        Guest     @relation(fields: [guestId], references: [id])
  guestId      Int
}""",
  "Library": """datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model Author {
  id           Int       @id @default(autoincrement())
  createdAt    DateTime  @default(now())
  updatedAt    DateTime  @updatedAt
  name         String
  books        Book[]
}

model Book {
  id           Int       @id @default(autoincrement())
  createdAt    DateTime  @default(now())
  updatedAt    DateTime  @updatedAt
  title        String
  isbn         String    @unique
  description  String?
  author       Author    @relation(fields: [authorId], references: [id])
  authorId     Int
  copies       BookCopy[]
}

model BookCopy {
  id           Int       @id @default(autoincrement())
  createdAt    DateTime  @default(now())
  updatedAt    DateTime  @updatedAt
  book         Book      @relation(fields: [bookId], references: [id])
  bookId       Int
  isAvailable  Boolean   @default(true)
  borrowings   Borrowing[]
}

model Member {
  id           Int       @id @default(autoincrement())
  createdAt    DateTime  @default(now())
  updatedAt    DateTime  @updatedAt
  firstName    String
  lastName     String
  email        String    @unique
  phoneNumber  String?
  borrowings   Borrowing[]
}

model Borrowing {
  id           Int       @id @default(autoincrement())
  createdAt    DateTime  @default(now())
  updatedAt    DateTime  @updatedAt
  bookCopy     BookCopy  @relation(fields: [bookCopyId], references: [id])
  bookCopyId   Int
  member       Member    @relation(fields: [memberId], references: [id])
  memberId     Int
  returnDate   DateTime
  returned     Boolean   @default(false)
}""",
  "Employee": """datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model Employee {
  id           Int       @id @default(autoincrement())
  createdAt    DateTime  @default(now())
  updatedAt    DateTime  @updatedAt
  firstName    String
  lastName     String
  email        String    @unique
  phoneNumber  String?
  position     String
  department   Department @relation(fields: [departmentId], references: [id])
  departmentId Int
  manager      Employee? @relation("ManagerToEmployee", fields: [managerId], references: [id])
  managerId    Int?
  subordinates Employee[] @relation("ManagerToEmployee")
}

model Department {
  id           Int       @id @default(autoincrement())
  createdAt    DateTime  @default(now())
  updatedAt    DateTime  @updatedAt
  name         String
  employees    Employee[]
}""",
  "Student": """datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model Student {
  id             Int        @id @default(autoincrement())
  createdAt      DateTime   @default(now())
  updatedAt      DateTime   @updatedAt
  firstName      String
  lastName       String
  email          String     @unique
  phoneNumber    String?
  enrollmentID   String     @unique
  courses        CourseEnrollment[]
  attendances    Attendance[]
  grades         Grade[]
  guardians      Guardian[]
}

model Teacher {
  id             Int        @id @default(autoincrement())
  createdAt      DateTime   @default(now())
  updatedAt      DateTime   @updatedAt
  firstName      String
  lastName       String
  email          String     @unique
  phoneNumber    String?
  department     Department @relation(fields: [departmentId], references: [id])
  departmentId   Int
  classes        Class[]
}

model Department {
  id             Int        @id @default(autoincrement())
  createdAt      DateTime   @default(now())
  updatedAt      DateTime   @updatedAt
  name           String
  teachers       Teacher[]
}

model Course {
  id             Int        @id @default(autoincrement())
  createdAt      DateTime   @default(now())
  updatedAt      DateTime   @updatedAt
  name           String
  code           String     @unique
  department     Department @relation(fields: [departmentId], references: [id])
  departmentId   Int
  enrollments    CourseEnrollment[]
  assignments    Assignment[]
  exams          Exam[]
}

model CourseEnrollment {
  id             Int        @id @default(autoincrement())
  createdAt      DateTime   @default(now())
  updatedAt      DateTime   @updatedAt
  student        Student    @relation(fields: [studentId], references: [id])
  studentId      Int
  course         Course     @relation(fields: [courseId], references: [id])
  courseId       Int
  grades         Grade[]
}

model Assignment {
  id             Int        @id @default(autoincrement())
  createdAt      DateTime   @default(now())
  updatedAt      DateTime   @updatedAt
  title          String
  description    String
  dueDate        DateTime
  course         Course     @relation(fields: [courseId], references: [id])
  courseId       Int
  submissions    Submission[]
}

model Exam {
  id             Int        @id @default(autoincrement())
  createdAt      DateTime   @default(now())
  updatedAt      DateTime   @updatedAt
  title          String
  date           DateTime
  course         Course     @relation(fields: [courseId], references: [id])
  courseId       Int
  grades         Grade[]
}

model Submission {
  id             Int        @id @default(autoincrement())
  createdAt      DateTime   @default(now())
  updatedAt      DateTime   @updatedAt
  student        Student    @relation(fields: [studentId], references: [id])
  studentId      Int
  assignment     Assignment @relation(fields: [assignmentId], references: [id])
  assignmentId   Int
  content        String
  grade          Grade?
}

model Attendance {
  id             Int        @id @default(autoincrement())
  createdAt      DateTime   @default(now())
  updatedAt      DateTime   @updatedAt
  student        Student    @relation(fields: [studentId], references: [id])
  studentId      Int
  class          Class      @relation(fields: [classId], references: [id])
  classId        Int
  status         AttendanceStatus
}

enum AttendanceStatus {
  Present
  Absent
}

model Guardian {
  id             Int        @id @default(autoincrement())
  createdAt      DateTime   @default(now())
  updatedAt      DateTime   @updatedAt
  firstName      String
  lastName       String
  email          String     @unique
  phoneNumber    String?
  students       Student[]
}""",
  "Custom": ""
};
