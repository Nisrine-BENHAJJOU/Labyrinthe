#include <iostream>
#include <vector>
#include <queue>
#include <unordered_map>
#include <unordered_set>
#include <string>
#include <nlohmann/json.hpp>
#include <crow.h>
#include <crow/middlewares/cors.h>
#include <thread>
#include <chrono>

using json = nlohmann::json;

struct Point {
    int row, col;
    bool operator==(const Point& other) const {
        return row == other.row && col == other.col;
    }
    bool operator<(const Point& other) const {
        return std::tie(row, col) < std::tie(other.row, other.col);
    }
};

namespace std {
    template <> struct hash<Point> {
        size_t operator()(const Point& p) const {
            return hash<int>()(p.row) ^ hash<int>()(p.col);
        }
    };
}

std::vector<Point> dijkstra(const Point& start, const Point& end, const std::unordered_set<std::string>& walls, int rows, int cols, std::vector<Point>& explored) {
    std::cout << "Running Dijkstra..." << std::endl;

    std::priority_queue<std::pair<int, Point>, std::vector<std::pair<int, Point>>, std::greater<>> pq;
    std::unordered_map<Point, int> cost;
    std::unordered_map<Point, Point> parent;
    pq.push({ 0, start });
    cost[start] = 0;

    std::vector<std::pair<int, int>> directions = { {-1, 0}, {1, 0}, {0, -1}, {0, 1} };

    while (!pq.empty()) {
        auto topElement = pq.top(); pq.pop();
        int current_cost = topElement.first;
        Point current = topElement.second;

        explored.push_back(current);
        if (current == end) break;

        for (const auto& dir : directions) {
            Point neighbor = { current.row + dir.first, current.col + dir.second };
            std::string key = std::to_string(neighbor.row) + "-" + std::to_string(neighbor.col);
            int new_cost = current_cost + 1;

            if (neighbor.row >= 0 && neighbor.row < rows && neighbor.col >= 0 && neighbor.col < cols && !walls.count(key) && (!cost.count(neighbor) || new_cost < cost[neighbor])) {
                pq.push({ new_cost, neighbor });
                cost[neighbor] = new_cost;
                parent[neighbor] = current;
            }
        }
    }

    std::vector<Point> path;
    if (parent.find(end) == parent.end()) return path;

    for (Point at = end; !(at == start); at = parent[at]) {
        path.push_back(at);
    }
    path.push_back(start);
    std::reverse(path.begin(), path.end());
    return path;
}


std::vector<Point> bfs(const Point& start, const Point& end, const std::unordered_set<std::string>& walls, int rows, int cols, std::vector<Point>& explored) {
    std::cout << "Running BFS..." << std::endl;

    std::queue<Point> q;
    std::unordered_map<Point, Point> parent;
    std::unordered_set<Point> visited;

    q.push(start);
    visited.insert(start);

    std::vector<std::pair<int, int>> directions = { {-1, 0}, {1, 0}, {0, -1}, {0, 1} };

    while (!q.empty()) {
        Point current = q.front(); q.pop();
        explored.push_back(current);
        if (current == end) break;

        for (const auto& dir : directions) {
            Point neighbor = { current.row + dir.first, current.col + dir.second };
            std::string key = std::to_string(neighbor.row) + "-" + std::to_string(neighbor.col);

            if (neighbor.row >= 0 && neighbor.row < rows && neighbor.col >= 0 && neighbor.col < cols &&
                !walls.count(key) && !visited.count(neighbor)) {
                q.push(neighbor);
                visited.insert(neighbor);
                parent[neighbor] = current;
            }
        }
    }

    std::vector<Point> path;
    if (parent.find(end) == parent.end()) return path;

    for (Point at = end; !(at == start); at = parent[at]) {
        path.push_back(at);
    }
    path.push_back(start);
    std::reverse(path.begin(), path.end());
    return path;
}

int main() {
    crow::App<crow::CORSHandler> app;
    auto& cors = app.get_middleware<crow::CORSHandler>().global();

    cors.global().headers("X-Custom-Header", "Upgrade-Insecure-Requests").methods("POST"_method, "GET"_method)
        .prefix("/cors").origin("http://localhost:3000").prefix("/nocors").ignore();

    CROW_ROUTE(app, "/cors").methods("POST"_method)([](const crow::request& req) {
        auto data = json::parse(req.body);
        std::vector<std::vector<int>> grid = data["grid"];

        int rows = grid.size();
        int cols = grid[0].size();
        Point start, end;
        std::unordered_set<std::string> walls;
        std::vector<Point> explored;

        for (int i = 0; i < rows; i++) {
            for (int j = 0; j < cols; j++) {
                if (grid[i][j] == 1) start = { i, j };
                else if (grid[i][j] == 2) end = { i, j };
                else if (grid[i][j] == -1) walls.insert(std::to_string(i) + "-" + std::to_string(j));
            }
        }

        std::vector<Point> path = (data["algorithm"] == "bfs") ? bfs(start, end, walls, rows, cols, explored) : dijkstra(start, end, walls, rows, cols, explored);
        json response;

        response["path"] = json::array();
        response["explored"] = json::array();

        for (const auto& p : explored) {
            response["explored"].push_back({ p.row, p.col });
        }
        for (const auto& p : path) {
            response["path"].push_back({ p.row, p.col });
        }

        return crow::response(200, response.dump());
       });

    std::cout << "Server started on port 8000" << std::endl;
    app.port(8000).multithreaded().run();
}
