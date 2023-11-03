--USE master

--IF EXISTS (SELECT name FROM master.sys.databases WHERE name='University')
--DROP DATABASE University
--GO

--CREATE DATABASE University
--GO

USE University
GO

---- Створення таблиці Students (студенти) 
--CREATE TABLE Students ( 
--	StudentID INT PRIMARY KEY IDENTITY(1,1), 
--	FirstName NVARCHAR(50), 
--	LastName NVARCHAR(50), 
--	DateOfBirth DATE 
--);
--GO

---- Створення таблиці Professors (викладачі)
--CREATE TABLE Professors (
--	ProfessorID INT PRIMARY KEY IDENTITY(1,1),
--    FirstName NVARCHAR(50),
--    LastName NVARCHAR(50)
--);
--GO

---- Створення таблиці Courses (курси) 
--CREATE TABLE Courses ( 
--	CourseID INT PRIMARY KEY IDENTITY(1,1), 
--	CourseName NVARCHAR(100), 
--	ProfessorID INT FOREIGN KEY REFERENCES Professors(ProfessorID) 
--);
--GO

---- Створення таблиці Enrollments (записи на курси) 
--CREATE TABLE Enrollments ( 
--	EnrollmentID INT PRIMARY KEY IDENTITY(1,1), 
--	StudentID INT FOREIGN KEY REFERENCES Students(StudentID), 
--	CourseID INT FOREIGN KEY REFERENCES Courses(CourseID), 
--	EnrollmentDate DATE 
--);
--GO

----Створення таблиці Grades (оцінки) 
--CREATE TABLE Grades ( 
--	GradeID INT PRIMARY KEY IDENTITY(1,1), 
--	EnrollmentID INT FOREIGN KEY REFERENCES Enrollments(EnrollmentID), 
--	Grade INT 
--);

--INSERT INTO Students
--VALUES ('Julia','Pott','2003-04-04'),('Doug','Rattmann','2004-07-11'),('Lydia','Allen','2002-10-02')
--GO

--INSERT INTO Professors
--VALUES ('Cave','Johnson')
--GO

--INSERT INTO Courses
--VALUES ('Math',1),('Physics',1)
--GO

--INSERT INTO Enrollments
--VALUES (1,1,GETDATE()), (2,2,GETDATE()), (3,1,GETDATE())
--GO

--INSERT INTO Grades
--VALUES (1,10),(1,12),(1,10),(2,6),(2,11),(2,9),(3,11),(1,9)
--GO

PRINT('------------------------------------------------------------')
BEGIN
  DECLARE @firstname nvarchar(50),@lastname nvarchar(50)
  DECLARE cur_students_random CURSOR SCROLL
  FOR SELECT FirstName, LastName FROM Students
  OPEN cur_students_random
  DECLARE @i int=0, @rand int=ABS(CHECKSUM(NEWID()) % 6) + 1
  WHILE @i<=4
  BEGIN
	SET @rand=ABS(CHECKSUM(NEWID()) % 6)
  	FETCH RELATIVE @rand FROM cur_students_random INTO @firstname, @lastname
  	PRINT @firstname + ' ' + @lastname
	SET @i+=1
  END
 
  CLOSE cur_students_random
  DEALLOCATE cur_students_random
END

PRINT('------------------------------------------------------------')
--Курсор для обчислення середньої оцінки для кожного студента з непарного рядка таблиці
  BEGIN
  DECLARE @averagegrade nvarchar(50)
  DECLARE cur_student_course_grades CURSOR SCROLL
  FOR SELECT FirstName,LastName FROM Students

  OPEN cur_student_course_grades
  FETCH FIRST FROM cur_student_course_grades INTO @firstname, @lastname
  SET @averagegrade=(SELECT AVG(Grade) FROM Students,Courses,Enrollments,Grades WHERE Enrollments.StudentID=Students.StudentID AND Enrollments.CourseID=Courses.CourseID AND Grades.EnrollmentID=Enrollments.EnrollmentID AND FirstName=@firstname AND @lastname=LastName)
  PRINT @firstname + ' ' + @lastname + ' ' + @averagegrade
  WHILE @@FETCH_STATUS=0
  BEGIN 
    FETCH RELATIVE 2 FROM cur_student_course_grades INTO @firstname, @lastname
	IF (@@FETCH_STATUS=0)
	BEGIN
	SET @averagegrade=(SELECT AVG(Grade) FROM Students,Courses,Enrollments,Grades WHERE Enrollments.StudentID=Students.StudentID AND Enrollments.CourseID=Courses.CourseID AND Grades.EnrollmentID=Enrollments.EnrollmentID AND FirstName=@firstname AND @lastname=LastName)
    PRINT @firstname + ' ' + @lastname + ' ' + @averagegrade
	END
  END
  
  CLOSE cur_student_course_grades
  DEALLOCATE cur_student_course_grades
END

PRINT('------------------------------------------------------------')
--Курсор для змінни оцінки на 1 бал в таблиці Grades для перших п’яти рядків
BEGIN
  DECLARE @grade nvarchar(50)
  DECLARE cur_grade_change CURSOR 
  FOR SELECT Grade FROM Grades
 
  OPEN cur_grade_change
  FETCH cur_grade_change INTO @grade
  SET @i=0
  WHILE @i<5
  BEGIN
	UPDATE Grades
	SET Grade=1 WHERE CURRENT OF cur_grade_change
    FETCH NEXT FROM cur_grade_change INTO @grade
	SET @i+=1
  END
  
  CLOSE cur_grade_change
  DEALLOCATE cur_grade_change
END