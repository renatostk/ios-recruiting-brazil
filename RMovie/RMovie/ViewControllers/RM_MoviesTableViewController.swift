//
//  RM_MoviesTableViewController.swift
//  RMovie
//
//  Created by Renato Mori on 04/10/2018.
//  Copyright © 2018 Renato Mori. All rights reserved.
//
import Foundation
import UIKit

class RM_MoviesTableViewController: UITableViewController, UISearchBarDelegate{
    
    var movies : RM_HTTP_Movies?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        self.movies = appDelegate.movies!;
        
        self.movies?.viewController = self;
        self.srcBusca.delegate = self;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.tableView.reloadData();
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        appDelegate.moviesFilter = self.movies?.moviesFilter;
    }
    
    //MARK: - Search
    
    @IBOutlet weak var srcBusca: UISearchBar!
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
        {
            self.movies?.moviesFilter.titleSearch = searchText;
            self.movies?.moviesFilter.applyFilters();
            self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.movies?.moviesFilter == nil ||

            (self.movies?.moviesFilter.count)! == 0 && (self.movies?.moviesFilter.movies.count)! < (self.movies?.total_results)!){
            self.movies?.getMore();
        }
        return self.movies?.moviesFilter == nil ? 0 : (self.movies?.moviesFilter.count)!;
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! RM_MovieTableViewCell;
        
        DispatchQueue.global(qos: .background).async {
            
            var movie : RM_Movie?;
            
            movie = self.movies?.getMovie(index: indexPath.row) ;
            
            DispatchQueue.main.async {
                if(movie == nil){
                    return;
                }
                if(movie?.poster_path != nil){
                    cell.imgPoster.imageFromServerURL("https://image.tmdb.org/t/p/w500\(String((movie?.poster_path)!))", placeHolder:nil);
                }else{
                    cell.imgPoster.image = nil;
                }
                cell.lblTitle.text = movie?.title;
                cell.lblYear.text = String((movie?.release_date?.prefix(4))!);
                cell.lblDescricao.text = movie?.overview;
                
                if(Favorite.store.hasId(id: (movie?.id)!)){
                    cell.imgFavorite?.image = UIImage(named: "favorite_full_icon");
                }else{
                    cell.imgFavorite?.image = UIImage(named: "favorite_empty_icon");
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        
        appDelegate.selectedMovie =  self.movies?.getMovie(index: indexPath.row);
    }
    
    
    
}
