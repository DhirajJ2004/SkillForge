import '../models/project_model.dart';

class ProjectsSeed {
  static List<Project> getInitialProjects() {
    return [
      Project(
        id: 'proj_1',
        monthNumber: 1,
        title: 'Python Expense Tracker',
        description:
            'A CLI and SQLite-backed personal finance manager that tracks incomes and expenses, categorizes spending, and generates monthly summary analytics.',
        technologies: ['Python 3', 'SQLite3', 'Rich CLI', 'CSV Export'],
        githubUrl: 'https://github.com/developer/python-expense-tracker',
        liveUrl: '',
        notes:
            'Focus on robust input validation, clean modular functions, and relational database schema design.',
        tasks: const [
          ProjectTask(id: 'p1_t1', title: 'Design SQLite database schema for categories and expenses'),
          ProjectTask(id: 'p1_t2', title: 'Implement CRUD operations for transactions'),
          ProjectTask(id: 'p1_t3', title: 'Add category-wise monthly spending summaries'),
          ProjectTask(id: 'p1_t4', title: 'Implement CSV export and import functionality'),
          ProjectTask(id: 'p1_t5', title: 'Write unit tests with pytest for calculation logic'),
        ],
      ),
      Project(
        id: 'proj_2',
        monthNumber: 2,
        title: 'Personal Developer Portfolio',
        description:
            'Modern, responsive developer portfolio showcasing projects, interactive live demos, technical blog posts, and contact form with dark mode support.',
        technologies: ['React', 'TypeScript', 'Tailwind CSS', 'Vite', 'Framer Motion'],
        githubUrl: 'https://github.com/developer/modern-portfolio',
        liveUrl: 'https://developer-portfolio-demo.vercel.app',
        notes:
            'Prioritize Lighthouse score 95+, semantic HTML, smooth micro-interactions, and mobile responsiveness.',
        tasks: const [
          ProjectTask(id: 'p2_t1', title: 'Design responsive layout with dark/light mode toggle'),
          ProjectTask(id: 'p2_t2', title: 'Build hero section with interactive code playground preview'),
          ProjectTask(id: 'p2_t3', title: 'Implement filterable projects showcase with tech tags'),
          ProjectTask(id: 'p2_t4', title: 'Create experience and education timeline component'),
          ProjectTask(id: 'p2_t5', title: 'Add validated contact form connected to EmailJS or serverless API'),
          ProjectTask(id: 'p2_t6', title: 'Deploy on Vercel with custom domain and OpenGraph tags'),
        ],
      ),
      Project(
        id: 'proj_3',
        monthNumber: 2,
        title: 'Weather Application',
        description:
            'Real-time weather dashboard featuring 7-day forecasts, geolocation search, hourly temperature graphs, and weather alert notifications.',
        technologies: ['React', 'OpenWeatherMap API', 'Chart.js', 'Lucide Icons'],
        githubUrl: 'https://github.com/developer/weather-forecast-app',
        liveUrl: 'https://weather-forecast-app.vercel.app',
        notes:
            'Demonstrates asynchronous data fetching, error handling for invalid cities, debounced search, and browser location API.',
        tasks: const [
          ProjectTask(id: 'p3_t1', title: 'Set up OpenWeatherMap API integration with environment keys'),
          ProjectTask(id: 'p3_t2', title: 'Implement debounced city search with autocomplete suggestions'),
          ProjectTask(id: 'p3_t3', title: 'Build current weather summary card with dynamic weather icons'),
          ProjectTask(id: 'p3_t4', title: 'Render 24-hour temperature forecast chart using Chart.js'),
          ProjectTask(id: 'p3_t5', title: 'Save favorite locations into local storage'),
        ],
      ),
      Project(
        id: 'proj_4',
        monthNumber: 3,
        title: 'Job Portal Full-Stack App',
        description:
            'End-to-end full-stack platform where employers post developer roles and candidates search, filter, and apply with uploaded resumes.',
        technologies: ['FastAPI', 'PostgreSQL', 'SQLAlchemy', 'React', 'JWT Auth'],
        githubUrl: 'https://github.com/developer/job-portal-platform',
        liveUrl: 'https://job-portal-api.onrender.com',
        notes:
            'Focuses on relational data modeling, role-based authorization (candidate vs recruiter), and pagination.',
        tasks: const [
          ProjectTask(id: 'p4_t1', title: 'Design database models: Users, Companies, Jobs, Applications'),
          ProjectTask(id: 'p4_t2', title: 'Implement JWT authentication and role-based permissions'),
          ProjectTask(id: 'p4_t3', title: 'Build REST endpoints with filter, sort, and pagination'),
          ProjectTask(id: 'p4_t4', title: 'Connect React frontend with protected dashboard routes'),
          ProjectTask(id: 'p4_t5', title: 'Implement resume file upload with validation and storage'),
          ProjectTask(id: 'p4_t6', title: 'Write comprehensive integration tests with pytest TestClient'),
        ],
      ),
      Project(
        id: 'proj_5',
        monthNumber: 4,
        title: 'AI PDF Research Assistant',
        description:
            'Retrieval Augmented Generation (RAG) platform that accepts research PDFs, extracts vectors into ChromaDB, and allows users to chat with documents with exact page citations.',
        technologies: ['FastAPI', 'LangChain', 'ChromaDB', 'OpenAI API', 'Streamlit / React'],
        githubUrl: 'https://github.com/developer/ai-pdf-research-assistant',
        liveUrl: 'https://ai-pdf-assistant-demo.streamlit.app',
        notes:
            'Master document chunking strategies, semantic similarity search, and source-grounded prompt engineering.',
        tasks: const [
          ProjectTask(id: 'p5_t1', title: 'Create frontend user interface with PDF dropzone'),
          ProjectTask(id: 'p5_t2', title: 'Build backend upload system with PDF text extraction and chunking'),
          ProjectTask(id: 'p5_t3', title: 'Generate high-dimensional vector embeddings with OpenAI'),
          ProjectTask(id: 'p5_t4', title: 'Store and index embeddings in ChromaDB with metadata'),
          ProjectTask(id: 'p5_t5', title: 'Build RAG retrieval pipeline with top-k context injection'),
          ProjectTask(id: 'p5_t6', title: 'Implement streaming chat interface with source citations'),
          ProjectTask(id: 'p5_t7', title: 'Add robust error handling and token count guards'),
          ProjectTask(id: 'p5_t8', title: 'Containerize with Docker and deploy on cloud server'),
        ],
      ),
      Project(
        id: 'proj_6',
        monthNumber: 5,
        title: 'AI Trading Research Platform',
        description:
            'Autonomous market sentiment and financial news analysis agent system using tool calling, multi-container Docker Compose, and automated AWS EC2 deployment.',
        technologies: ['Python', 'Docker Compose', 'AWS EC2', 'FastAPI', 'Redis', 'Financial APIs'],
        githubUrl: 'https://github.com/developer/ai-trading-research-platform',
        liveUrl: '',
        notes:
            'Showcases production DevOps skills: multi-stage Docker builds, Nginx reverse proxy, CI/CD with GitHub Actions, and background celery/redis tasks.',
        tasks: const [
          ProjectTask(id: 'p6_t1', title: 'Set up financial news scraper and real-time stock ticker API'),
          ProjectTask(id: 'p6_t2', title: 'Implement autonomous agent with function calling for ticker lookups'),
          ProjectTask(id: 'p6_t3', title: 'Build asynchronous background worker with Redis and Celery'),
          ProjectTask(id: 'p6_t4', title: 'Create multi-stage production Dockerfiles for frontend and backend'),
          ProjectTask(id: 'p6_t5', title: 'Write docker-compose.yml orchestrating app, database, and Redis'),
          ProjectTask(id: 'p6_t6', title: 'Configure AWS EC2 instance with Nginx and Let\'s Encrypt SSL'),
          ProjectTask(id: 'p6_t7', title: 'Set up automated GitHub Actions workflow for deployment on push'),
        ],
      ),
    ];
  }
}
