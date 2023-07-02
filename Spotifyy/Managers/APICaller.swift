//
//  APICaller.swift
//  Spotifyy
//
//  Created by Yashika Tonk on 07/04/23.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    private init() {}
    
    struct Constants {
        static let baseAPIURL = "https://api.spotify.com/v1"
    }
    
    enum APIError: Error {
        case failedToGetData
    }
    
//MARK: - Albums
    
    public func getAlbumDetails(for album: Album, completion: @escaping (Result<AlbumDetailsResponse,Error>) -> Void) {
        
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/albums/" + album.id),
            type: .GET) { request in
                let task = URLSession.shared.dataTask(with: request) { data, _, error in
                    guard let data = data, error == nil else {
                        completion(.failure(APIError.failedToGetData))
                        return
                    }
                    do {
                        let result = try JSONDecoder().decode(AlbumDetailsResponse.self, from: data)
                        completion(.success(result))
                    }
                    catch{
                        completion(.failure(error))
                    }
                }
                task.resume()
            }
    }
    
    public func getCurrentUserAlbums(completion: @escaping (Result<[Album],Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/me/albums"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                    
                do {
                    let result = try JSONDecoder().decode(LibraryAlbumResponse.self, from: data)
                    completion(.success(result.items.compactMap({$0.album})))
                }
                catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func saveAlbum(album: Album, completion: @escaping (Bool) -> Void){
            createRequest(with: URL(string: Constants.baseAPIURL + "/me/albums?ids=\(album.id)"),
                          type: .PUT) { baseRequest in
                var request = baseRequest
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard
                          let code = (response as? HTTPURLResponse)?.statusCode,
                          error == nil else{
                        completion(false)
                        return
                    }
                    print(code)
                    completion(code == 200)
                }
                task.resume()
            }
        }
    
//MARK: - Playlists

    public func getPlaylistDetails(for playlist: Playlist, completion: @escaping (Result<PlaylistDetailsResponse,Error>) -> Void) {
        
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/playlists/" + playlist.id),
            type: .GET) { request in
                let task = URLSession.shared.dataTask(with: request) { data, _, error in
                    guard let data = data, error == nil else {
                        completion(.failure(APIError.failedToGetData))
                        return
                    }
                    do {
                        let result = try JSONDecoder().decode(PlaylistDetailsResponse.self, from: data)
                        completion(.success(result))
                    }
                    catch{
                        completion(.failure(error))
                    }
                }
                task.resume()
            }
    }
        
    public func getCurrentUserPlaylists(completion: @escaping (Result<[Playlist], Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/me/playlists/?limit=50"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                    
                do {
                    let result = try JSONDecoder().decode(LibraryPlaylistsResponse.self, from: data)
                    completion(.success(result.items))
                }
                catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
        
        public func createPlaylist(with name: String, completion: @escaping (Bool) -> Void){
            getCurrentUserProfile { [weak self] result in
                switch result{
                case .success(let profile):
                    let urlString = Constants.baseAPIURL + "/users/\(profile.id)/playlists"
                    
                    self?.createRequest(with: URL(string: urlString), type: .POST) { baseRequest in
                        var request = baseRequest
                        let json = [
                            "name" : name
                        ]
                        request.httpBody = try? JSONSerialization.data(withJSONObject: json,options: .fragmentsAllowed)
                        let task = URLSession.shared.dataTask(with: request) { data, _, error in
                            guard let data = data, error == nil else {
                                completion(false)
                                return
                            }
                            do {
                                let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                                if let response = result as? [String: Any], response["id"] as? String != nil {
                                    print("created")
                                    completion(true)
                                }
                                else { print("failed")
                                    completion(false) }
                            }
                            catch {
                                completion(false)
                            }
                        }
                        task.resume()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        public func addTrackToPlaylist(track: AudioTrack, playlist: Playlist, completion: @escaping (Bool) -> Void){
            createRequest(with: URL(string: Constants.baseAPIURL + "/playlists/\(playlist.id)/tracks"), type: .POST) { baseRequest in
                var request = baseRequest
                let json = [
                    "uris": [
                        "spotify:track:\(track.id)"
                    ]
                ]
                request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let task = URLSession.shared.dataTask(with: request) { data, _, error in
                    guard let data = data, error == nil else {
                        completion(false)
                        return
                    }
                    do{
                        let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        if let response = result as? [String: Any], response["snapshot_id"] as? String != nil {
                            completion(true)
                        }
                        else { completion(false) }
                    }
                    catch {
                        completion(false)
                    }
                }
                task.resume()
            }
        }
        public func removeTrackFromPlaylist(track: AudioTrack, playlist: Playlist, completion: @escaping (Bool) -> Void){
            createRequest(with: URL(string: Constants.baseAPIURL + "/playlists/\(playlist.id)/tracks"), type: .DELETE) { baseRequest in
                var request = baseRequest
                let json: [String: Any] = [
                    "tracks": [
                        [
                            "uri": "spotify:track:\(track.id)"
                        ]
                    ]
                ]
                request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let task = URLSession.shared.dataTask(with: request) { data, _, error in
                    guard let data = data, error == nil else {
                        completion(false)
                        return
                    }
                    do{
                        let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        if let response = result as? [String: Any], response["snapshot_id"] as? String != nil {
                            completion(true)
                        }
                        else { completion(false) }
                    }
                    catch {
                        completion(false)
                    }
                }
                task.resume()
            }
        }
    
//MARK: - Profile
// to get Current Profile of the the logged in user
    
    public func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/me"), type: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(UserProfile.self, from: data)
                    //print(result)
                    completion(.success(result))
                }
                catch{
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
// MARK: - Browse
 // to get new Released albums
    
    public func getNewReleases(completion: @escaping ((Result<NewReleasesResponse, Error>)) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/browse/new-releases?limit=48"),type: .GET) { request in
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                               return
                }
                
                do{
                    let result = try JSONDecoder().decode(NewReleasesResponse.self, from: data)
                    completion(.success(result))
                }
                catch{
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
        
    }
    
 // to get all the featured playlist
    
    public func getFeaturedPlaylist(completion: @escaping ((Result<FeaturedPlaylistsResponse, Error>)->Void)) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/browse/featured-playlists?limit=20"), type: .GET) { request in
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do{
                    let result = try JSONDecoder().decode(FeaturedPlaylistsResponse.self, from: data)
                    completion(.success(result))
                }
                catch{
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getRecommendations(genres: Set<String>, completion: @escaping ((Result<RecommendationResponse,Error>)->Void)){
        let seeds = genres.joined(separator: ",")
        createRequest(with: URL(string: Constants.baseAPIURL + "/recommendations?limit=40&seed_genres=\(seeds)"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do{
                    let result = try JSONDecoder().decode(RecommendationResponse.self, from: data)
                    completion(.success(result))
                }
                catch{
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
 // to get recommended tracks
    public func getRecommendedGenres(completion: @escaping ((Result<RecommendedGenresResponse, Error>)->Void)) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/recommendations/available-genre-seeds"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do{
                    let result = try JSONDecoder().decode(RecommendedGenresResponse.self, from: data)
                    completion(.success(result))
                }
                catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    //MARK: - Cotegory
    
    public func getCategories(completion: @escaping (Result<[Category],Error>) -> Void){
        createRequest(with: URL(string: Constants.baseAPIURL + "/browse/categories?limit=50"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(AllCategoriesResponse.self,from: data)
                    completion(.success(result.categories.items))
                }
                catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getCategoryPlaylists(category: Category, completion: @escaping (Result<[Playlist],Error>) -> Void){
        createRequest(with: URL(string: Constants.baseAPIURL + "/browse/categories/\(category.id)/playlists?limit=50"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(CategoryPlaylistsResponse.self, from: data)
                    completion(.success(result.playlists.items))
                }
                catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    //MARK: - Search Result
    
    public func search(with query: String, completion: @escaping (Result<[SearchResult],Error>) -> Void){
        //converting query into url while passing to the createRequest
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/search?limit=10&type=album,artist,playlist,track&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"),
            type: .GET){ request in
                print( request.url?.absoluteString ?? "none")
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else
                {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(SearchResultResponse.self, from: data)
                    
                    var searchResults: [SearchResult] = []
                    searchResults.append(contentsOf: result.tracks.items.compactMap({SearchResult.track(model: $0) }))
                    searchResults.append(contentsOf: result.albums.items.compactMap({SearchResult.album(model: $0) }))
                    searchResults.append(contentsOf: result.artists.items.compactMap({SearchResult.artist(model: $0) }))
                    searchResults.append(contentsOf: result.playlists.items.compactMap({SearchResult.playlist(model: $0) }))
                    
                    completion(.success(searchResults))
                }
                catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Private
    
    enum HTTPMethod: String {
        case GET
        case PUT
        case POST
        case DELETE
    }
    
    
    private func createRequest(with url: URL?,type: HTTPMethod, completion: @escaping ((URLRequest)->Void)) {
        AuthManager.shared.withValidToken { token in
            guard let apiurl = url else { return }
            var request = URLRequest(url: apiurl)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            completion(request)
        }
        
    }
    
    /*private func getTask(request: URLRequest, type: Codable.Type, completion: @escaping ((Result<Codable, Error>)->Void))
    {
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(APIError.failedToGetData))
                return
            }
                
            do{
                let result = try JSONDecoder().decode(type.self, from: data)
                print(result)
                completion(.success(result))
            }
            catch{
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
        task.resume()
    }*/
}
    

                       
