# WasteWise India - System Flow Diagram

## Overall System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    WasteWise India Platform                     │
├─────────────────────────────────────────────────────────────────┤
│  Multi-Language Support (English, Hindi, Tamil)                │
│  Real-time Translation with Google ML Kit                      │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    User Registration Flow                       │
└─────────────────────────────────────────────────────────────────┘
                                │
                ┌───────────────┼───────────────┐
                ▼               ▼               ▼
        ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
        │   Citizen   │ │  Collector  │ │    Admin    │
        │ (Provider)  │ │             │ │             │
        └─────────────┘ └─────────────┘ └─────────────┘
                │               │               │
                ▼               ▼               ▼
        ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
        │ Mandatory   │ │ Safety &    │ │ Leadership  │
        │ Training    │ │ Collection  │ │ Training    │
        │ Required    │ │ Training    │ │             │
        └─────────────┘ └─────────────┘ └─────────────┘
```

## Detailed User Journey Flow

### 1. Citizen (Waste Provider) Flow

```
Registration → Role Selection → Mandatory Training → Full Access
     │              │                    │              │
     ▼              ▼                    ▼              ▼
┌─────────┐  ┌─────────────┐  ┌─────────────────┐  ┌─────────────┐
│Personal │  │Select Role: │  │• Basic Waste    │  │Dashboard    │
│Info +   │  │Citizen      │  │  Management     │  │Access       │
│Address  │  │             │  │• Segregation    │  │             │
│         │  │             │  │• Composting     │  │             │
│         │  │             │  │• Plastic Reuse  │  │             │
└─────────┘  └─────────────┘  └─────────────────┘  └─────────────┘
                                        │
                                        ▼
                              ┌─────────────────┐
                              │Training Complete│
                              │Certificate      │
                              │Issued           │
                              └─────────────────┘
```

### 2. Waste Reporting Flow

```
Report Button → Location Capture → Photo/Video Links → Categorization → Submit
     │               │                    │                │           │
     ▼               ▼                    ▼                ▼           ▼
┌─────────┐  ┌─────────────┐  ┌─────────────────┐  ┌─────────┐  ┌─────────┐
│Quick    │  │GPS Auto     │  │Google Drive     │  │Waste    │  │+50      │
│Report   │  │Location     │  │Links Input      │  │Type &   │  │Points   │
│Access   │  │Detection    │  │(Photos/Videos)  │  │Priority │  │Awarded  │
└─────────┘  └─────────────┘  └─────────────────┘  └─────────┘  └─────────┘
                                                                      │
                                                                      ▼
                                                              ┌─────────────┐
                                                              │Report in    │
                                                              │Community    │
                                                              │Feed         │
                                                              └─────────────┘
```

### 3. Collector Assignment & Resolution Flow

```
Report Submitted → Auto Assignment → Collector Notification → Work Start → Resolution
       │                │                    │                  │           │
       ▼                ▼                    ▼                  ▼           ▼
┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  ┌─────────┐  ┌─────────┐
│Report       │  │Nearest      │  │Push Notification│  │Status   │  │Report   │
│Enters       │  │Available    │  │+ Map Location   │  │Update   │  │Marked   │
│System       │  │Collector    │  │                 │  │to "In   │  │Resolved │
│             │  │Selected     │  │                 │  │Progress"│  │         │
└─────────────┘  └─────────────┘  └─────────────────┘  └─────────┘  └─────────┘
                                                                      │
                                                                      ▼
                                                              ┌─────────────┐
                                                              │Points to    │
                                                              │Reporter &   │
                                                              │Collector    │
                                                              └─────────────┘
```

### 4. Training System Flow

```
Training Access → Module Selection → Video Content → Interactive Exercise → Quiz → Certificate
       │               │                │               │                │        │
       ▼               ▼                ▼               ▼                ▼        ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────┐ ┌─────────┐
│Check        │ │Progressive  │ │Educational  │ │Hands-on     │ │Knowledge│ │Digital  │
│Mandatory    │ │Unlocking    │ │Video        │ │Practice     │ │Test     │ │Badge    │
│Requirements │ │System       │ │Content      │ │Activities   │ │(80%+)   │ │Issued   │
└─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘ └─────────┘ └─────────┘
```

### 5. Green Champion Program Flow

```
Application → Eligibility Check → Training Complete → Area Assignment → Monitoring Tools
     │             │                    │                   │               │
     ▼             ▼                    ▼                   ▼               ▼
┌─────────┐ ┌─────────────┐ ┌─────────────────┐ ┌─────────────┐ ┌─────────────┐
│Submit   │ │• 1000+ Points│ │Advanced         │ │Area Code    │ │Dashboard    │
│Area     │ │• Training    │ │Leadership       │ │Assignment   │ │+ Monitoring │
│Details  │ │  Complete    │ │Training         │ │             │ │Tools        │
│         │ │• Community   │ │                 │ │             │ │             │
│         │ │  Participation│ │                 │ │             │ │             │
└─────────┘ └─────────────┘ └─────────────────┘ └─────────────┘ └─────────────┘
```

### 6. Rewards & Incentives Flow

```
Earn Points → Browse Store → Select Reward → Redemption → Delivery/Digital Access
     │            │             │             │              │
     ▼            ▼             ▼             ▼              ▼
┌─────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────┐ ┌─────────────┐
│Report   │ │Eco-friendly │ │Physical/    │ │Points   │ │Order        │
│Waste    │ │Products     │ │Digital      │ │Deducted │ │Tracking     │
│+50 pts  │ │Discounts    │ │Certificates │ │         │ │System       │
│         │ │Certificates │ │             │ │         │ │             │
│Training │ │             │ │             │ │         │ │             │
│+200 pts │ │             │ │             │ │         │ │             │
│         │ │             │ │             │ │         │ │             │
│Games    │ │             │ │             │ │         │ │             │
│+100 pts │ │             │ │             │ │         │ │             │
└─────────┘ └─────────────┘ └─────────────┘ └─────────┘ └─────────────┘
```

## Data Flow Architecture

### Firebase Collections Structure

```
Firebase Firestore
├── users/
│   ├── {userId}/
│   │   ├── personalInfo
│   │   ├── role (citizen/collector/admin)
│   │   ├── trainingProgress
│   │   ├── points
│   │   └── achievements
│   └── ...
├── reports/
│   ├── {reportId}/
│   │   ├── reporterInfo
│   │   ├── location (geopoint)
│   │   ├── wasteType
│   │   ├── priority
│   │   ├── status
│   │   ├── imageUrls (Drive links)
│   │   └── timestamps
│   └── ...
├── facilities/
│   ├── {facilityId}/
│   │   ├── name
│   │   ├── type (recycling/wte/compost/biogas/scrap)
│   │   ├── location (geopoint)
│   │   ├── capacity
│   │   ├── operatingHours
│   │   └── contactInfo
│   └── ...
├── training_progress/
│   ├── {userId}/
│   │   ├── moduleCompletions
│   │   ├── certificates
│   │   └── scores
│   └── ...
├── green_champions/
│   ├── {championId}/
│   │   ├── userId
│   │   ├── areaCode
│   │   ├── responsibilities
│   │   └── performanceMetrics
│   └── ...
└── reward_redemptions/
    ├── {redemptionId}/
    │   ├── userId
    │   ├── rewardId
    │   ├── pointsUsed
    │   └── deliveryInfo
    └── ...
```

## Real-time Updates Flow

```
User Action → Provider State Update → Firebase Write → Real-time Listeners → UI Update
     │               │                      │                │                │
     ▼               ▼                      ▼                ▼                ▼
┌─────────┐  ┌─────────────┐  ┌─────────────────┐  ┌─────────────┐  ┌─────────┐
│Report   │  │WasteProvider│  │Firestore        │  │Stream       │  │Live     │
│Submit   │  │State Change │  │Document         │  │Listeners    │  │Feed     │
│         │  │             │  │Created          │  │             │  │Update   │
│Training │  │AuthProvider │  │                 │  │             │  │         │
│Complete │  │Points Update│  │User Document    │  │             │  │Points   │
│         │  │             │  │Updated          │  │             │  │Display  │
│Game     │  │GameProvider │  │                 │  │             │  │         │
│Finish   │  │Score Update │  │                 │  │             │  │         │
└─────────┘  └─────────────┘  └─────────────────┘  └─────────────┘  └─────────┘
```

## Security & Privacy Flow

```
User Data → Validation → Encryption → Firebase Rules → Secure Storage
     │           │           │             │              │
     ▼           ▼           ▼             ▼              ▼
┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────────┐ ┌─────────────┐
│Input    │ │Client   │ │Transport│ │Server-side  │ │Encrypted    │
│Forms    │ │Side     │ │Layer    │ │Validation   │ │Database     │
│         │ │Checks   │ │Security │ │Rules        │ │Storage      │
└─────────┘ └─────────┘ └─────────┘ └─────────────┘ └─────────────┘
```

## Gamification & Engagement Flow

```
User Activity → Points Calculation → Level Progression → Rewards Unlock → Community Recognition
      │               │                    │                │                │
      ▼               ▼                    ▼                ▼                ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────────┐ ┌─────────────┐ ┌─────────────┐
│• Report     │ │• Report: 50 │ │Beginner → Inter │ │New Rewards  │ │Leaderboard  │
│• Training   │ │• Training:  │ │Inter → Advanced │ │Available    │ │Updates      │
│• Games      │ │  200        │ │Advanced → Expert│ │             │ │             │
│• Community  │ │• Games: 100 │ │                 │ │Achievement  │ │Badge        │
│  Engagement │ │• Daily: 25  │ │                 │ │Badges       │ │Display      │
└─────────────┘ └─────────────┘ └─────────────────┘ └─────────────┘ └─────────────┘
```

## Monitoring & Analytics Flow

```
Data Collection → Processing → Analytics → Insights → Action Items
      │              │           │           │           │
      ▼              ▼           ▼           ▼           ▼
┌─────────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────────┐
│• User       │ │Real-time│ │Dashboard│ │• Waste  │ │• Policy     │
│  Activity   │ │Data     │ │Metrics  │ │  Trends │ │  Updates    │
│• Reports    │ │Aggreg-  │ │         │ │• Training│ │• Resource   │
│• Training   │ │ation    │ │• Usage  │ │  Gaps   │ │  Allocation │
│• Facility   │ │         │ │• Impact │ │• Facility│ │• Community  │
│  Usage      │ │         │ │• Growth │ │  Needs  │ │  Programs   │
└─────────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────────┘
```

## Integration Points

### External Services Integration
```
Google Services:
├── Firebase Auth (Authentication)
├── Firestore (Database)
├── Firebase Storage (Media - Drive Links)
├── Google Maps (Location Services)
├── ML Kit Translation (Multi-language)
└── Cloud Functions (Background Processing)

Government Integration Points:
├── CPCB Data Integration
├── ULB/GP Systems
├── Waste Management Facility APIs
└── Compliance Reporting Systems
```

### API Flow
```
Mobile App → Firebase SDK → Cloud Functions → External APIs → Government Systems
     │            │              │               │               │
     ▼            ▼              ▼               ▼               ▼
┌─────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│User     │ │Real-time    │ │Data         │ │Third-party  │ │Compliance   │
│Actions  │ │Sync         │ │Processing   │ │Services     │ │Reporting    │
│         │ │             │ │& Validation │ │             │ │             │
└─────────┘ └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘
```

## Scalability Architecture

```
National Deployment
├── State Level
│   ├── District Level
│   │   ├── ULB/GP Level
│   │   │   ├── Area Level (Green Champions)
│   │   │   │   ├── Community Groups
│   │   │   │   └── Individual Citizens
│   │   │   └── Waste Collection Teams
│   │   └── Facility Management
│   └── State Coordination
└── Central Monitoring & Policy
```

This system flow ensures:
- **Decentralized Monitoring**: Green Champions at area level
- **Mandatory Compliance**: Training requirements for all users
- **Real-time Tracking**: Live status updates and community engagement
- **Scalable Architecture**: Designed for national deployment
- **Multi-language Support**: Accessible to diverse Indian population
- **Cost-effective Storage**: Drive links instead of direct file uploads