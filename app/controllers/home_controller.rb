class HomeController < ApplicationController

  def search

    userInput = params[:username]

    usernameSearch = userInput.delete(' ')

    searchedUser = getUser(usernameSearch)

    if searchedUser["errors"]

      redirect_to new_path, notice: "Oh No! Could not find profile attached to that username - try searching for another profile"
    
    else 
      $username = usernameSearch
      displayUserInfo(searchedUser)
    end

  end

  def displayUserInfo(user)

    $userInfo = user["body"]

    $userRepos = getRepos($userInfo["repos"])

    @top_languages = {}

    languages = {}

    repoCount = 0

    mostRecentRepos = []


    for i in $userRepos

      if repoCount < 5 
        h = Hash.new
        h["link"] = i["html_url"]
        h["language"] = i["language"]
        h["last_updated"] = i["updated_at"]
        mostRecentRepos << h
      end

      repoCount += 1

      if languages[i["language"]]
        languages[i["language"]] = languages[i["language"]] + 1
      else 
        languages[i["language"]] = 1
      end
    end

    numberOfRepos = []

    languages.each_value {|val| numberOfRepos << val}

    sortedRepos = numberOfRepos.sort.reverse

    @numberOfLanguages = sortedRepos.length()

    $all_repos = languages
    
    $fav_lang = nil

    if sortedRepos.length() === 1
      $fav_lang = languages.key(sortedRepos[0])
    else 
      $fav_lang = getPredictedLanguage(languages, sortedRepos, mostRecentRepos)
    end


    $splitObj = getLanguageRanks(languages, repoCount)


    if $fav_lang
      redirect_to show_path
    end

  end

  def getPredictedLanguage(lang, sorted, recent)

    one = lang.key(sorted[0])
    two = lang.key(sorted[1])

    if sorted[0] > sorted[1]

      return lang.key(sorted[0])
    
    else 

      return findMostRecentFav(recent)

    end
  end

  def findMostRecentFav(r)

    recentLanguages = {}

    count = 0

    lastRepoLang = nil

    for i in r 

      if count < 1
        lastrepoLang = i["language"]
      end

      if recentLanguages[i["language"]]
        recentLanguages[i["language"]] = recentLanguages[i["language"]] + 1
      else 
        recentLanguages[i["language"]] = 1
      end

    end

    sortedRecent = recentLanguages.sort_by{|k, v| -v }

    langSelect = nil

    if sortedRecent.length() === 1

      langSelect = sortedRecent[0][0]

    elsif sortedRecent[0][1] > sortedRecent[1][1]
      langSelect = sortedRecent[0][0]
    else
      langSelect = lastRepoLang
    end

    return langSelect
  end 

  def getLanguageRanks(languages, repoCount)


    sortedArray = languages.sort_by{|k, v| -v }

    count = 1

    rankHash = Hash.new

    for i in sortedArray

      if i[0]
        tempHash = Hash.new
        tempHash["language"] = i[0]
        tempHash["amount"] = i[1]
        tempHash["repo_percentage"] = getLangPercent(i[1].to_f, repoCount.to_f)
        rankHash[count] = tempHash
        count += 1
      end

    end 

    $styleOne = nil
    $styleTwo = nil
    $styleThree = nil

    if rankHash[1]
      $styleOne = rankHash[1]["repo_percentage"].to_int
    end

    if rankHash[2]
      $styleTwo = rankHash[2]["repo_percentage"].to_int
    end

    if rankHash[3]
      $styleThree = rankHash[3]["repo_percentage"].to_int
    end

    return rankHash

  end 

  def getLangPercent(amount, count)
    total = amount / count
    return total * 100
  end

  def getUser(username)

    userReturn = Hash.new
    userDetails = "https://api.github.com/users/#{username}"
    
    res = HTTParty.get(userDetails)

    if res.code === 200

      currentUser = Hash.new

      user = JSON.parse(res.body)

      currentUser["git_hub_link"] = user["html_url"]
      currentUser["avatar"] = user["avatar_url"]
      currentUser["name"] = user["name"]
      currentUser["bio"] = user["bio"]
      currentUser["followers"] = user["followers"]
      currentUser["number_of_repos"] = user["public_repos"]
      currentUser["member_since"] = user["created_at"].to_time.strftime("%d of %B, %Y")
      currentUser["repos"] = user["repos_url"]

      userReturn["body"] = currentUser
      userReturn["errors"] = false

      return userReturn

    else

      userReturn["body"] = res.body
      userReturn["errors"] = true

      return userReturn

    end
  end 

  def topThreeData(langHash, rank)
    puts rank
    denom = rank[0] + rank[1] + rank[2]
    puts denom
  end

  def getRepos(repoUrl)

    repos = "#{repoUrl}?sort=updated"

    res = HTTParty.get(repos)

    if res.code === 200

      return JSON.parse(res.body)

    end

  end

  def show

    if !$fav_lang

      redirect_to new_path

    end
  end

  def create 
  end

  def index

  end
end
