#!/usr/bin/env swift
// Makes the transcript demo's clip from a Particle podcast clip: its audio, cut to length, and its word-level transcript.
// Usage: PARTICLE_API_KEY=… swift scripts/make-clip.swift <clip ID> [seconds]

import AVFoundation
import Foundation

struct Clip: Decodable {
    struct Episode: Decodable {
        let slug: String
    }

    let episode: Episode
    let startSeconds: Double
    let durationSeconds: Double
    let audioUrl: URL
}

struct WordPage: Decodable {
    struct Word: Decodable {
        let text: String
        let type: String
        let startSeconds: Double
        let endSeconds: Double
        let speaker: String?
    }

    let words: [Word]
}

struct Word: Encodable {
    let text: String
    let type: String
    let start: Double
    let end: Double
    let speakerId: String
}

struct Transcript: Encodable {
    let words: [Word]
}

let arguments = CommandLine.arguments.dropFirst()
guard let clipID = arguments.first, let key = ProcessInfo.processInfo.environment["PARTICLE_API_KEY"] else {
    print("Usage: PARTICLE_API_KEY=… swift scripts/make-clip.swift <clip ID> [seconds]")
    exit(1)
}

let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase

func get<T: Decodable>(_ path: String, _ query: [URLQueryItem] = []) async throws -> T {
    var components = URLComponents(string: "https://api.particle.pro/v1/podcasts/\(path)")
    components?.queryItems = query.isEmpty ? nil : query
    guard let url = components?.url else { throw URLError(.badURL) }
    var request = URLRequest(url: url)
    request.setValue(key, forHTTPHeaderField: "X-API-Key")
    let (data, response) = try await URLSession.shared.data(for: request)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
        throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: String(decoding: data, as: UTF8.self)])
    }
    return try decoder.decode(T.self, from: data)
}

let clip: Clip = try await get("clips/\(clipID)")
let length = min(arguments.dropFirst().first.flatMap(Double.init) ?? clip.durationSeconds, clip.durationSeconds)
let page: WordPage = try await get("episodes/\(clip.episode.slug)/transcript/words", [
    URLQueryItem(name: "start", value: String(clip.startSeconds)),
    URLQueryItem(name: "end", value: String(clip.startSeconds + length)),
])

let output = URL(filePath: #filePath).deletingLastPathComponent()
    .appending(path: "../DelightfulTextDriven/DelightfulTextDriven/Talk/Advanced/Clip")
    .standardized
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)

let (temporary, _) = try await URLSession.shared.download(from: clip.audioUrl)
let download = temporary.deletingPathExtension().appendingPathExtension(clip.audioUrl.pathExtension)
try FileManager.default.moveItem(at: temporary, to: download)
guard let export = AVAssetExportSession(asset: AVURLAsset(url: download), presetName: AVAssetExportPresetAppleM4A) else {
    print("Can't export \(clip.audioUrl)")
    exit(1)
}
export.timeRange = CMTimeRange(start: .zero, duration: CMTime(seconds: length, preferredTimescale: 600))
let audio = output.appending(path: "clip.m4a")
try? FileManager.default.removeItem(at: audio)
try await export.export(to: audio, as: .m4a)

let words = page.words.map {
    Word(text: $0.text, type: $0.type, start: $0.startSeconds - clip.startSeconds, end: $0.endSeconds - clip.startSeconds, speakerId: $0.speaker ?? "")
}
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted]
try encoder.encode(Transcript(words: words)).write(to: output.appending(path: "clip.json"))
print("Wrote \(length) s and \(words.filter { $0.type == "word" }.count) words to \(output.path)")
