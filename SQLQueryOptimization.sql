CREATE DATABASE normDB;
USE normDB;

-- Project Table
CREATE TABLE Project (
    ProjectCode VARCHAR(10) PRIMARY KEY,
    ProjectTitle VARCHAR(50) NOT NULL,
    ProjectManager VARCHAR(50) NOT NULL,
    ProjectBudget INT NOT NULL
);

-- Employee Table
CREATE TABLE Employee (
    EmployeeNo VARCHAR(10) PRIMARY KEY,
    EmployeeName VARCHAR(50) NOT NULL,
    HourlyRate DECIMAL(5, 2) NOT NULL
);

-- Department Table
CREATE TABLE Department (
    DepartmentNo VARCHAR(10) PRIMARY KEY,
    DepartmentName VARCHAR(50) NOT NULL
);

-- Junction Table (Many-to-Many Relationship)
CREATE TABLE ProjectEmployee (
    ProjectCode VARCHAR(10),
    EmployeeNo VARCHAR(10),
    DepartmentNo VARCHAR(10),
    PRIMARY KEY (ProjectCode, EmployeeNo, DepartmentNo),
    FOREIGN KEY (ProjectCode) REFERENCES Project(ProjectCode) ON DELETE CASCADE,
    FOREIGN KEY (EmployeeNo) REFERENCES Employee(EmployeeNo) ON DELETE CASCADE,
    FOREIGN KEY (DepartmentNo) REFERENCES Department(DepartmentNo) ON DELETE CASCADE
);

-- Indexes for performance improvement
CREATE INDEX idx_ProjectEmployee_Proj ON ProjectEmployee(ProjectCode);
CREATE INDEX idx_ProjectEmployee_Emp ON ProjectEmployee(EmployeeNo);
CREATE INDEX idx_ProjectEmployee_Dept ON ProjectEmployee(DepartmentNo);




SELECT ProjectCode, ProjectTitle, ProjectManager, ProjectBudget 
FROM Project 
WHERE ProjectCode <> 'PC045';



SELECT ProjectCode, ProjectTitle 
FROM Project 
WHERE ProjectCode NOT IN ('PC010', 'PC045');



SELECT COUNT(ProjectCode) AS ProjectsAboveBudget 
FROM Project 
WHERE ProjectBudget > 15000;




WITH EmployeeProjects AS (
    SELECT EmployeeNo, COUNT(DISTINCT ProjectCode) AS ProjectCount
    FROM ProjectEmployee
    GROUP BY EmployeeNo
)
SELECT e.EmployeeNo, e.EmployeeName
FROM Employee e
JOIN EmployeeProjects ep ON e.EmployeeNo = ep.EmployeeNo
WHERE ep.ProjectCount > 1;



SELECT EmployeeNo, EmployeeName
FROM Employee e
WHERE NOT EXISTS (
    SELECT 1 FROM ProjectEmployee pe WHERE pe.EmployeeNo = e.EmployeeNo
);




SELECT pe.EmployeeNo, e.EmployeeName
FROM ProjectEmployee pe
JOIN Employee e ON pe.EmployeeNo = e.EmployeeNo
GROUP BY pe.EmployeeNo, e.EmployeeName
HAVING COUNT(DISTINCT pe.DepartmentNo) > 1;



SELECT d.DepartmentNo, d.DepartmentName, COUNT(pe.EmployeeNo) AS TotalEmployees
FROM Department d
LEFT JOIN ProjectEmployee pe ON d.DepartmentNo = pe.DepartmentNo
GROUP BY d.DepartmentNo, d.DepartmentName;



SELECT DISTINCT d.DepartmentNo, d.DepartmentName
FROM Department d
JOIN ProjectEmployee pe ON d.DepartmentNo = pe.DepartmentNo
WHERE pe.ProjectCode = 'PC045';



SELECT e.EmployeeName, d.DepartmentName, p.ProjectTitle
FROM Employee e
JOIN ProjectEmployee pe ON e.EmployeeNo = pe.EmployeeNo
JOIN Project p ON pe.ProjectCode = p.ProjectCode
JOIN Department d ON pe.DepartmentNo = d.DepartmentNo
WHERE e.EmployeeName LIKE 'B%';



SELECT e.EmployeeNo, SUM(e.HourlyRate * 104) AS TotalWages
FROM Employee e
JOIN ProjectEmployee pe ON e.EmployeeNo = pe.EmployeeNo
WHERE e.EmployeeNo = 'S1001'
GROUP BY e.EmployeeNo;



CREATE PROCEDURE GetEmployeesByDepartment (@DeptNo VARCHAR(10))
AS
BEGIN
    SELECT e.EmployeeNo, e.EmployeeName, e.HourlyRate
    FROM Employee e
    JOIN ProjectEmployee pe ON e.EmployeeNo = pe.EmployeeNo
    WHERE pe.DepartmentNo = @DeptNo;
END;



EXEC GetEmployeesByDepartment 'L004';



CREATE PROCEDURE GetProjectsBelowAvgBudget
AS
BEGIN
    SELECT ProjectCode, ProjectTitle, ProjectBudget
    FROM Project
    WHERE ProjectBudget < (SELECT AVG(ProjectBudget) FROM Project);
END;



EXEC GetProjectsBelowAvgBudget;



CREATE PROCEDURE GetTopDepartmentsByWages
AS
BEGIN
    SELECT TOP 3 d.DepartmentNo, d.DepartmentName, AVG(e.HourlyRate) AS AvgWages
    FROM Department d
    JOIN ProjectEmployee pe ON d.DepartmentNo = pe.DepartmentNo
    JOIN Employee e ON pe.EmployeeNo = e.EmployeeNo
    GROUP BY d.DepartmentNo, d.DepartmentName
    ORDER BY AvgWages DESC;
END;


EXEC GetTopDepartmentsByWages;



SELECT p.ProjectCode, p.ProjectTitle, e.EmployeeNo, e.EmployeeName, d.DepartmentNo, d.DepartmentName, e.HourlyRate
FROM Project p
JOIN ProjectEmployee pe ON p.ProjectCode = pe.ProjectCode
JOIN Employee e ON pe.EmployeeNo = e.EmployeeNo
JOIN Department d ON pe.DepartmentNo = d.DepartmentNo;
